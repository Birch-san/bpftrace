#include "semantic_analyser.h"
#include "arch/arch.h"
#include "ast.h"
#include "codegen_helper.h"
#include "fake_map.h"
#include "list.h"
#include "log.h"
#include "parser.tab.hh"
#include "printf.h"
#include "tracepoint_format_parser.h"
#include "usdt.h"
#include "utils.h"
#include <algorithm>
#include <cstring>
#include <regex>
#include <string>
#include <sys/stat.h>

#include <bcc/libbpf.h>

namespace bpftrace {
namespace ast {

static const std::map<std::string, std::tuple<size_t, bool>>& getIntcasts() {
  static const std::map<std::string, std::tuple<size_t, bool>> intcasts = {
    {"uint8", std::tuple<size_t, bool>{1, false}},
    {"int8", std::tuple<size_t, bool>{1, true}},
    {"uint16", std::tuple<size_t, bool>{2, false}},
    {"int16", std::tuple<size_t, bool>{2, true}},
    {"uint32", std::tuple<size_t, bool>{4, false}},
    {"int32", std::tuple<size_t, bool>{4, true}},
    {"uint64", std::tuple<size_t, bool>{8, false}},
    {"int64", std::tuple<size_t, bool>{8, true}},
  };
  return intcasts;
}

void SemanticAnalyser::visit(Integer &integer)
{
  integer.type = CreateInt64();
}

void SemanticAnalyser::visit(PositionalParameter &param)
{
  param.type = CreateInt64();
  switch (param.ptype)
  {
    case PositionalParameterType::positional:
      if (param.n <= 0)
        LOG(ERROR, param.loc, err_)
            << "$" << std::to_string(param.n) + " is not a valid parameter";
      if (is_final_pass()) {
        std::string pstr = bpftrace_.get_param(param.n, param.is_in_str);
        if (!is_numeric(pstr) && !param.is_in_str)
        {
          LOG(ERROR, param.loc, err_)
              << "$" << param.n << " used numerically but given \"" << pstr
              << "\". Try using str($" << param.n << ").";
        }
        if (is_numeric(pstr) && param.is_in_str)
        {
          // This is blocked due to current limitations in our codegen
          LOG(ERROR, param.loc, err_)
              << "$" << param.n
              << " used in str(), but given numeric value: " << pstr
              << ". Try $" << param.n << " instead of str($" << param.n << ").";
        }
      }
      break;
    case PositionalParameterType::count:
      if (is_final_pass() && param.is_in_str) {
        LOG(ERROR, param.loc, err_) << "use $#, not str($#)";
      }
      break;
    default:
      LOG(ERROR, param.loc, err_) << "unknown parameter type";
      param.type = CreateNone();
      break;
  }
}

void SemanticAnalyser::visit(String &string)
{
  if (!is_compile_time_func(func_) && string.str.size() > bpftrace_.strlen_ - 1)
  {
    LOG(ERROR, string.loc, err_)
        << "String is too long (over " << bpftrace_.strlen_
        << " bytes): " << string.str;
  }
  string.type = CreateString(bpftrace_.strlen_);
  if (is_final_pass())
    bpftrace_.str_map_keys_.emplace(static_cast<Node *>(&string),
                                    bpftrace_.str_map_keys_.size());
}

void SemanticAnalyser::visit(StackMode &mode)
{
  mode.type = CreateStackMode();
  if (mode.mode == "bpftrace") {
    mode.type.stack_type.mode = bpftrace::StackMode::bpftrace;
  } else if (mode.mode == "perf") {
    mode.type.stack_type.mode = bpftrace::StackMode::perf;
  } else {
    mode.type = CreateNone();
    LOG(ERROR, mode.loc, err_) << "Unknown stack mode: '" + mode.mode + "'";
  }
}

void SemanticAnalyser::visit(Identifier &identifier)
{
  if (bpftrace_.enums_.count(identifier.ident) != 0) {
    identifier.type = CreateUInt64();
  }
  else if (bpftrace_.structs_.count(identifier.ident) != 0)
  {
    identifier.type = CreateCast(8 * bpftrace_.structs_[identifier.ident].size);
  }
  else if (getIntcasts().count(identifier.ident) != 0)
  {
    identifier.type = CreateInt(
        8 * std::get<0>(getIntcasts().at(identifier.ident)));
  }
  else {
    identifier.type = CreateNone();
    LOG(ERROR, identifier.loc, err_)
        << "Unknown identifier: '" + identifier.ident + "'";
  }
}

void SemanticAnalyser::builtin_args_tracepoint(AttachPoint *attach_point,
                                               Builtin &builtin)
{
  /*
   * tracepoint wildcard expansion, part 2 of 3. This:
   * 1. expands the wildcard, then sets args to be the first matched probe.
   *    This is so that enough of the type information is available to
   *    survive the later semantic analyser checks.
   * 2. sets is_tparg so that codegen does the real type setting after
   *    expansion.
   */
  auto matches = bpftrace_.find_wildcard_matches(*attach_point);
  if (!matches.empty())
  {
    auto &match = *matches.begin();
    std::string tracepoint_struct = TracepointFormatParser::get_struct_name(
        attach_point->target, match);
    Struct &cstruct = bpftrace_.structs_[tracepoint_struct];
    builtin.type = CreateCTX(cstruct.size, tracepoint_struct);
    builtin.type.is_pointer = true;
    builtin.type.is_tparg = true;
  }
}

ProbeType SemanticAnalyser::single_provider_type(void)
{
  ProbeType type = ProbeType::invalid;

  for (auto &attach_point : *probe_->attach_points)
  {
    ProbeType ap = probetype(attach_point->provider);

    if (type == ProbeType::invalid)
      type = ap;

    if (type != ap)
      return ProbeType::invalid;
  }

  return type;
}

void SemanticAnalyser::visit(Builtin &builtin)
{
  if (builtin.ident == "ctx")
  {
    builtin.type = SizedType(Type::ctx, sizeof(uintptr_t), false);
    builtin.type.is_pointer = true;

    ProbeType pt = probetype((*probe_->attach_points)[0]->provider);
    bpf_prog_type bt = progtype(pt);
    for (auto &attach_point : *probe_->attach_points)
    {
      ProbeType pt = probetype(attach_point->provider);
      bpf_prog_type bt2 = progtype(pt);
      if (bt != bt2)
        LOG(ERROR, builtin.loc, err_)
            << "ctx cannot be used in different BPF program types: "
            << progtypeName(bt) << " and " << progtypeName(bt2);
    }
    switch (bt)
    {
      case BPF_PROG_TYPE_KPROBE:
        builtin.type.cast_type = "struct pt_regs";
        break;
      case BPF_PROG_TYPE_TRACEPOINT:
        LOG(ERROR, builtin.loc, err_)
            << "Use args instead of ctx in tracepoint";
        break;
      case BPF_PROG_TYPE_PERF_EVENT:
        builtin.type.cast_type = "struct bpf_perf_event_data";
        break;
      default:
        LOG(ERROR, builtin.loc, err_) << "invalid program type";
        break;
    }
  }
  else if (builtin.ident == "nsecs" || builtin.ident == "elapsed" ||
           builtin.ident == "pid" || builtin.ident == "tid" ||
           builtin.ident == "cgroup" || builtin.ident == "uid" ||
           builtin.ident == "gid" || builtin.ident == "cpu" ||
           builtin.ident == "curtask" || builtin.ident == "rand")
  {
    builtin.type = CreateUInt64();
    if (builtin.ident == "cgroup" &&
        !feature_.has_helper_get_current_cgroup_id())
    {
      LOG(ERROR, builtin.loc, err_)
          << "BPF_FUNC_get_current_cgroup_id is not available for your kernel "
             "version";
    }
    else if (builtin.ident == "elapsed")
    {
      needs_elapsed_map_ = true;
    }
    else if (builtin.ident == "curtask")
    {
      /*
      * Retype curtask to its original type: struct task_truct.
      */
      builtin.type.type = Type::cast;
      builtin.type.cast_type = "struct task_struct";
      builtin.type.is_pointer = true;
    }
  }
  else if (builtin.ident == "retval")
  {
    ProbeType type = single_provider_type();

    if (type == ProbeType::kretprobe || type == ProbeType::uretprobe)
    {
      builtin.type = CreateUInt64();
    }
    else if (type == ProbeType::kfunc || type == ProbeType::kretfunc)
    {
      auto it = ap_args_.find("$retval");

      if (it != ap_args_.end())
        builtin.type = it->second;
      else
        LOG(ERROR, builtin.loc, err_) << "Can't find a field $retval";
    }
    else
    {
      LOG(ERROR, builtin.loc, err_)
          << "The retval builtin can only be used with 'kretprobe' and "
          << "'uretprobe' and 'kfunc' probes"
          << (type == ProbeType::tracepoint ? " (try to use args->ret instead)"
                                            : "");
    }
  }
  else if (builtin.ident == "kstack") {
    builtin.type = CreateStack(true, StackType());
    needs_stackid_maps_.insert(builtin.type.stack_type);
  }
  else if (builtin.ident == "ustack") {
    builtin.type = CreateStack(false, StackType());
    needs_stackid_maps_.insert(builtin.type.stack_type);
  }
  else if (builtin.ident == "comm") {
    builtin.type = CreateString(COMM_SIZE);
  }
  else if (builtin.ident == "func") {
    for (auto &attach_point : *probe_->attach_points)
    {
      ProbeType type = probetype(attach_point->provider);
      if (type == ProbeType::kprobe ||
          type == ProbeType::kretprobe)
        builtin.type = CreateKSym();
      else if (type == ProbeType::uprobe || type == ProbeType::uretprobe)
        builtin.type = CreateUSym();
      else
        LOG(ERROR, builtin.loc, err_)
            << "The func builtin can not be used with '"
            << attach_point->provider << "' probes";
    }
  }
  else if (!builtin.ident.compare(0, 3, "arg") && builtin.ident.size() == 4 &&
      builtin.ident.at(3) >= '0' && builtin.ident.at(3) <= '9') {
    for (auto &attach_point : *probe_->attach_points)
    {
      ProbeType type = probetype(attach_point->provider);
      if (type != ProbeType::kprobe &&
          type != ProbeType::uprobe &&
          type != ProbeType::usdt)
        LOG(ERROR, builtin.loc, err_)
            << "The " << builtin.ident << " builtin can only be used with "
            << "'kprobes', 'uprobes' and 'usdt' probes";
    }
    int arg_num = atoi(builtin.ident.substr(3).c_str());
    if (arg_num > arch::max_arg())
      LOG(ERROR, builtin.loc, err_)
          << arch::name() << " doesn't support " << builtin.ident;
    builtin.type = CreateUInt64();
  }
  else if (!builtin.ident.compare(0, 4, "sarg") && builtin.ident.size() == 5 &&
      builtin.ident.at(4) >= '0' && builtin.ident.at(4) <= '9') {
    for (auto &attach_point : *probe_->attach_points)
    {
      ProbeType type = probetype(attach_point->provider);
      if (type != ProbeType::kprobe && type != ProbeType::uprobe)
        LOG(ERROR, builtin.loc, err_)
            << "The " + builtin.ident
            << " builtin can only be used with 'kprobes' and 'uprobes' probes";
      if (is_final_pass() &&
          (attach_point->address != 0 || attach_point->func_offset != 0)) {
        // If sargX values are needed when using an offset, they can be stored in a map
        // when entering the function and then referenced from an offset-based probe
        LOG(WARNING, builtin.loc, out_)
            << "Using an address offset with the sargX built-in can"
               "lead to unexpected behavior ";
      }
    }
    builtin.type = CreateUInt64();
  }
  else if (builtin.ident == "probe") {
    builtin.type = CreateProbe();
    probe_->need_expansion = true;
  }
  else if (builtin.ident == "username") {
    builtin.type = CreateUsername();
  }
  else if (builtin.ident == "cpid") {
    if (!has_child_)
    {
      LOG(ERROR, builtin.loc, err_)
          << "cpid cannot be used without child command";
    }
    builtin.type = CreateUInt32();
  }
  else if (builtin.ident == "args") {
    for (auto &attach_point : *probe_->attach_points)
    {
      ProbeType type = probetype(attach_point->provider);

      if (type == ProbeType::tracepoint)
      {
        probe_->need_expansion = true;
        builtin_args_tracepoint(attach_point, builtin);
      }
    }

    ProbeType type = single_provider_type();

    if (type == ProbeType::tracepoint)
    {
      // no special action in here
    }
    else if (type == ProbeType::kfunc || type == ProbeType::kretfunc)
    {
      builtin.type = SizedType(Type::ctx, 0);
      builtin.type.is_kfarg = true;
    }
    else
    {
      LOG(ERROR, builtin.loc, err_)
          << "The args builtin can only be used with tracepoint/kfunc probes ("
          << probetypeName(type) << " used here)";
    }
  }
  else {
    builtin.type = CreateNone();
    LOG(ERROR, builtin.loc, err_)
        << "Unknown builtin variable: '" << builtin.ident << "'";
  }
}

void SemanticAnalyser::visit(Call &call)
{
  // Check for unsafe-ness first. It is likely the most pertinent issue
  // (and should be at the top) for any function call.
  if (bpftrace_.safe_mode_ && is_unsafe_func(call.func)) {
    LOG(ERROR, call.loc, err_)
        << call.func << "() is an unsafe function being used in safe mode";
  }

  struct func_setter
  {
    func_setter(SemanticAnalyser &analyser, const std::string &s)
        : analyser_(analyser), old_func_(analyser_.func_)
    {
      analyser_.func_ = s;
    }

    ~func_setter()
    {
      analyser_.func_ = old_func_;
    }

  private:
    SemanticAnalyser &analyser_;
    std::string old_func_;
  };

  func_setter scope_bound_func_setter{ *this, call.func };

  if (call.vargs) {
    for (Expression *expr : *call.vargs) {
      expr->accept(*this);
    }
  }

  if (call.func == "hist") {
    check_assignment(call, true, false, false);
    check_nargs(call, 1);
    check_arg(call, Type::integer, 0);

    call.type = CreateHist();
  }
  else if (call.func == "lhist") {
    check_assignment(call, true, false, false);
    if (check_nargs(call, 4)) {
      check_arg(call, Type::integer, 0, false);
      check_arg(call, Type::integer, 1, true);
      check_arg(call, Type::integer, 2, true);
      check_arg(call, Type::integer, 3, true);
    }

    if (is_final_pass()) {
      Expression &min_arg = *call.vargs->at(1);
      Expression &max_arg = *call.vargs->at(2);
      Expression &step_arg = *call.vargs->at(3);
      Integer &min = static_cast<Integer&>(min_arg);
      Integer &max = static_cast<Integer&>(max_arg);
      Integer &step = static_cast<Integer&>(step_arg);
      if (step.n <= 0)
      {
        LOG(ERROR, call.loc, err_)
            << "lhist() step must be >= 1 (" << step.n << " provided)";
      }
      else
      {
        int buckets = (max.n - min.n) / step.n;
        if (buckets > 1000)
        {
          LOG(ERROR, call.loc, err_)
              << "lhist() too many buckets, must be <= 1000 (would need "
              << buckets << ")";
        }
      }
      if (min.n < 0)
      {
        LOG(ERROR, call.loc, err_)
            << "lhist() min must be non-negative (provided min " << min.n
            << ")";
      }
      if (min.n > max.n)
      {
        LOG(ERROR, call.loc, err_)
            << "lhist() min must be less than max (provided min " << min.n
            << " and max ";
      }
      if ((max.n - min.n) < step.n)
      {
        LOG(ERROR, call.loc, err_)
            << "lhist() step is too large for the given range (provided step "
            << step.n << " for range " << (max.n - min.n) << ")";
      }

      // store args for later passing to bpftrace::Map
      auto search = map_args_.find(call.map->ident);
      if (search == map_args_.end())
        map_args_.insert({call.map->ident, *call.vargs});
    }
    call.type = CreateLhist();
  }
  else if (call.func == "count") {
    check_assignment(call, true, false, false);
    check_nargs(call, 0);

    call.type = CreateCount(true);
  }
  else if (call.func == "sum") {
    bool sign = false;
    check_assignment(call, true, false, false);
    if (check_nargs(call, 1)) {
      check_arg(call, Type::integer, 0);
      sign = call.vargs->at(0)->type.IsSigned();
    }
    call.type = CreateSum(sign);
  }
  else if (call.func == "min") {
    bool sign = false;
    check_assignment(call, true, false, false);
    if (check_nargs(call, 1)) {
      check_arg(call, Type::integer, 0);
      sign = call.vargs->at(0)->type.IsSigned();
    }
    call.type = CreateMin(sign);
  }
  else if (call.func == "max") {
    bool sign = false;
    check_assignment(call, true, false, false);
    if (check_nargs(call, 1)) {
      check_arg(call, Type::integer, 0);
      sign = call.vargs->at(0)->type.IsSigned();
    }
    call.type = CreateMax(sign);
  }
  else if (call.func == "avg") {
    check_assignment(call, true, false, false);
    check_nargs(call, 1);
    check_arg(call, Type::integer, 0);
    call.type = CreateAvg(true);
  }
  else if (call.func == "stats") {
    check_assignment(call, true, false, false);
    check_nargs(call, 1);
    check_arg(call, Type::integer, 0);
    call.type = CreateStats(true);
  }
  else if (call.func == "delete") {
    check_assignment(call, false, false, false);
    if (check_nargs(call, 1)) {
      auto &arg = *call.vargs->at(0);
      if (!arg.is_map)
        LOG(ERROR, call.loc, err_) << "delete() expects a map to be provided";
    }

    call.type = CreateNone();
  }
  else if (call.func == "str") {
    if (check_varargs(call, 1, 2)) {
      check_arg(call, Type::integer, 0);
      call.type = CreateString(bpftrace_.strlen_);
      if (is_final_pass() && call.vargs->size() > 1) {
        check_arg(call, Type::integer, 1, false);
      }
      if (auto *param = dynamic_cast<PositionalParameter*>(call.vargs->at(0))) {
        param->is_in_str = true;
      }
    }
    if (is_final_pass())
      bpftrace_.str_map_keys_.emplace(static_cast<Node *>(&call),
                                      bpftrace_.str_map_keys_.size());
  }
  else if (call.func == "buf")
  {
    if (!check_varargs(call, 1, 2))
      return;

    auto &arg = *call.vargs->at(0);
    if (!(arg.type.IsIntTy() || arg.type.IsStringTy() || arg.type.IsArrayTy()))
      LOG(ERROR, call.loc, err_)
          << call.func
          << "() expects an integer, string, or array argument but saw "
          << typestr(arg.type.type);

    size_t max_buffer_size = bpftrace_.strlen_;
    size_t buffer_size = max_buffer_size;

    if (call.vargs->size() == 1)
      if (arg.type.IsArrayTy())
        buffer_size = arg.type.GetNumElements() * arg.type.GetElementTy()->size;
      else
        LOG(ERROR, call.loc, err_)
            << call.func << "() expects a length argument for non-array type "
            << typestr(arg.type.type);
    else
    {
      if (is_final_pass())
        check_arg(call, Type::integer, 1, false);

      auto &size_arg = *call.vargs->at(1);
      if (size_arg.is_literal)
        buffer_size = static_cast<Integer &>(size_arg).n;
    }

    if (buffer_size > max_buffer_size)
    {
      if (is_final_pass())
        LOG(WARNING, call.loc, out_)
            << call.func << "() length is too long and will be shortened to "
            << std::to_string(bpftrace_.strlen_)
            << " bytes (see BPFTRACE_STRLEN)";

      buffer_size = max_buffer_size;
    }

    call.type = CreateBuffer(buffer_size);

    max_buf_size_ = std::max(max_buf_size_, call.type.size);

    if (auto *param = dynamic_cast<PositionalParameter *>(call.vargs->at(0)))
    {
      param->is_in_str = true;
    }
    if (is_final_pass())
      bpftrace_.buf_map_keys_.emplace(static_cast<Node *>(&call),
                                      bpftrace_.buf_map_keys_.size());
  }
  else if (call.func == "ksym" || call.func == "usym") {
    if (check_nargs(call, 1)) {
      // allow symbol lookups on casts (eg, function pointers)
      auto &arg = *call.vargs->at(0);
      if (arg.type.type != Type::integer && arg.type.type != Type::cast)
        LOG(ERROR, call.loc, err_)
            << call.func << "() expects an integer or pointer argument";
    }

    if (call.func == "ksym")
      call.type = CreateKSym();
    else if (call.func == "usym")
      call.type = CreateUSym();
  }
  else if (call.func == "ntop") {
    if (!check_varargs(call, 1, 2))
      return;

    auto arg = call.vargs->at(0);
    if (call.vargs->size() == 2) {
      arg = call.vargs->at(1);
      check_arg(call, Type::integer, 0);
    }

    if (!arg->type.IsIntTy() && !arg->type.IsArray())
      LOG(ERROR, call.loc, err_)
          << call.func << "() expects an integer or array argument, got "
          << arg->type.type;

    // Kind of:
    //
    // struct {
    //   int af_type;
    //   union {
    //     char[4] inet4;
    //     char[16] inet6;
    //   }
    // }
    int buffer_size = 24;
    auto type = arg->type;

    if (arg->type.IsArray() && type.size != 4 && type.size != 16)
      LOG(ERROR, call.loc, err_)
          << call.func << "() argument must be 4 or 16 bytes in size";

    call.type = CreateInet(buffer_size);
  }
  else if (call.func == "join") {
    check_assignment(call, false, false, false);
    check_varargs(call, 1, 2);
    check_arg(call, Type::integer, 0);
    call.type = CreateNone();
    needs_join_map_ = true;

    if (is_final_pass()) {
      if (call.vargs && call.vargs->size() > 1) {
        if (check_arg(call, Type::string, 1, true)) {
          auto &join_delim_arg = *call.vargs->at(1);
          String &join_delim_str = static_cast<String&>(join_delim_arg);
          bpftrace_.join_args_.push_back(join_delim_str.str);
        }
      } else {
        std::string join_delim_default = " ";
        bpftrace_.join_args_.push_back(join_delim_default);
      }
    }
  }
  else if (call.func == "reg") {
    if (check_nargs(call, 1)) {
      for (auto &attach_point : *probe_->attach_points) {
        ProbeType type = probetype(attach_point->provider);
        if (type == ProbeType::tracepoint) {
          LOG(ERROR, call.loc, err_)
              << "The reg function cannot be used with 'tracepoint' probes";
          continue;
        }
      }

      if (check_arg(call, Type::string, 0, true)) {
        auto &arg = *call.vargs->at(0);
        auto &reg_name = static_cast<String&>(arg).str;
        int offset = arch::offset(reg_name);;
        if (offset == -1) {
          LOG(ERROR, call.loc, err_)
              << "'" << reg_name
              << "' is not a valid register on this architecture"
              << " (" << arch::name() << ")";
        }
      }
    }

    call.type = CreateUInt64();
  }
  else if (call.func == "kaddr") {
    if (check_nargs(call, 1)) {
      check_arg(call, Type::string, 0, true);
    }
    call.type = CreateUInt64();
  }
  else if (call.func == "uaddr")
  {
    if (!check_nargs(call, 1))
      return;
    if (!(check_arg(call, Type::string, 0, true) && check_symbol(call, 0)))
      return;

    std::vector<int> sizes;
    auto &name = static_cast<String &>(*call.vargs->at(0)).str;
    for (auto &ap : *probe_->attach_points)
    {
      ProbeType type = probetype(ap->provider);
      if (type != ProbeType::usdt && type != ProbeType::uretprobe &&
          type != ProbeType::uprobe)
      {
        LOG(ERROR, call.loc, err_)
            << "uaddr can only be used with u(ret)probes and usdt probes";
        sizes.push_back(0);
        continue;
      }
      struct symbol sym = {};
      int err = bpftrace_.resolve_uname(name, &sym, ap->target);
      if (err < 0 || sym.address == 0)
      {
        LOG(ERROR, call.loc, err_)
            << "Could not resolve symbol: " << ap->target << ":" << name;
      }
      sizes.push_back(sym.size);
    }

    for (size_t i = 1; i < sizes.size(); i++)
    {
      if (sizes.at(0) != sizes.at(i))
      {
        LOG(ERROR, call.loc, err_)
            << "Symbol size mismatch between probes. Symbol \"" << name
            << "\" has size " << sizes.at(0) << " for probe \""
            << probe_->attach_points->at(0)->name("") << "\" but size "
            << sizes.at(i) << " for probe \""
            << probe_->attach_points->at(i)->name("") << "\"";
      }
    }
    call.type = CreateUInt64();
    call.type.is_pointer = true;
    switch (sizes.at(0))
    {
      case 1:
      case 2:
      case 4:
        call.type.pointee_size = sizes.at(0);
        break;
      default:
        call.type.pointee_size = 8;
    }
  }
  else if (call.func == "cgroupid") {
    if (check_nargs(call, 1)) {
      check_arg(call, Type::string, 0, true);
    }
    call.type = CreateUInt64();
  }
  else if (call.func == "printf" || call.func == "system" || call.func == "cat")
  {
    needs_fmtstr_map_ = true;
    check_assignment(call, false, false, false);
    if (check_varargs(call, 1, 128))
    {
      check_arg(call, Type::string, 0, true);
      if (is_final_pass())
      {
        auto &fmt_arg = *call.vargs->at(0);
        String &fmt = static_cast<String&>(fmt_arg);
        std::vector<Field> args;
        size_t args_size = 0;
        for (auto iter = call.vargs->begin() + 1; iter != call.vargs->end();
             iter++)
        {
          auto ty = (*iter)->type;
          // Promote to 64-bit if it's not an aggregate type
          if (!ty.IsAggregate() && !ty.IsTimestampTy())
            ty.size = 8;
          args.push_back(Field{
            .type =  ty,
            .offset = 0,
            .is_bitfield = false,
            .bitfield = Bitfield{
              .read_bytes = 0,
              .access_rshift = 0,
              .mask = 0,
            },
          });
          /*
           * codegen allocates a non-packed struct, so we need to align struct
           * members to word size. this may be an overshoot (i.e. if a more
           * efficient pack is possible). that won't affect the IR emitted;
           * we'll just end up allocating a slightly bigger map than necessary.
           *
           * TODO: get access to llvm::DataLayout and actually measure the
           * formatString struct size
           */
          args_size += align_to(ty.size, 8);
        }
        max_fmtstr_args_size_ = std::max(max_fmtstr_args_size_, args_size);
        std::string msg = verify_format_string(fmt.str, args);
        if (msg != "")
        {
          LOG(ERROR, call.loc, err_) << msg;
        }

        if (call.func == "printf")
          bpftrace_.printf_args_.emplace_back(fmt.str, args);
        else if (call.func == "system")
          bpftrace_.system_args_.emplace_back(fmt.str, args);
        else
          bpftrace_.cat_args_.emplace_back(fmt.str, args);
      }
    }

    call.type = CreateNone();
  }
  else if (call.func == "exit") {
    check_assignment(call, false, false, false);
    check_nargs(call, 0);
  }
  else if (call.func == "print") {
    check_assignment(call, false, false, false);
    if (in_loop() && is_final_pass())
    {
      LOG(WARNING, call.loc, out_)
          << "Due to it's asynchronous nature using 'print()' in a loop can "
             "lead to unexpected behavior. The map will likely be updated "
             "before the runtime can 'print' it.";
    }
    if (check_varargs(call, 1, 3)) {
      auto &arg = *call.vargs->at(0);
      if (arg.is_map)
      {
        Map &map = static_cast<Map&>(arg);
        map.skip_key_validation = true;
        if (map.vargs != nullptr) {
          LOG(ERROR, call.loc, err_)
              << "The map passed to " << call.func << "() should not be "
              << "indexed by a key";
        }

        if (is_final_pass())
        {
          if (call.vargs->size() > 1)
            check_arg(call, Type::integer, 1, true);
          if (call.vargs->size() > 2)
            check_arg(call, Type::integer, 2, true);
          if (map.type.IsStatsTy() && call.vargs->size() > 1)
          {
            LOG(WARNING, call.loc, out_)
                << "print()'s top and div arguments are ignored when used on "
                   "stats() maps.";
          }
        }
      }
      // Note that IsPrintableTy() is somewhat disingenuous here. Printing a
      // non-map value requires being able to serialize the entire value, so
      // map-backed types like count(), min(), max(), etc. cannot be printed
      // through the non-map printing mechanism.
      //
      // We rely on the fact that semantic analysis enforces types like count(),
      // min(), max(), etc. to be assigned directly to a map. This ensures that
      // the previous `arg.is_map` arm is hit first.
      else if (arg.type.IsPrintableTy())
      {
        if (call.vargs->size() != 1)
          LOG(ERROR, call.loc, err_)
              << "Non-map print() only takes 1 argument, " << call.vargs->size()
              << " found";

        bpftrace_.non_map_print_args_.emplace_back(arg.type);
      }
      else
      {
        if (is_final_pass())
          LOG(ERROR, call.loc, err_) << arg.type << " type passed to "
                                     << call.func << "() is not printable";
      }
    }
  }
  else if (call.func == "clear") {
    check_assignment(call, false, false, false);
    if (check_nargs(call, 1)) {
      auto &arg = *call.vargs->at(0);
      if (!arg.is_map)
        LOG(ERROR, call.loc, err_) << "clear() expects a map to be provided";
      else {
        Map &map = static_cast<Map&>(arg);
        map.skip_key_validation = true;
        if (map.vargs != nullptr) {
          LOG(ERROR, call.loc, err_)
              << "The map passed to " << call.func << "() should not be "
              << "indexed by a key";
        }
      }
    }
  }
  else if (call.func == "zero") {
    check_assignment(call, false, false, false);
    if (check_nargs(call, 1)) {
      auto &arg = *call.vargs->at(0);
      if (!arg.is_map)
        LOG(ERROR, call.loc, err_) << "zero() expects a map to be provided";
      else {
        Map &map = static_cast<Map&>(arg);
        map.skip_key_validation = true;
        if (map.vargs != nullptr) {
          LOG(ERROR, call.loc, err_)
              << "The map passed to " << call.func << "() should not be "
              << "indexed by a key";
        }
      }
    }
  }
  else if (call.func == "time") {
    check_assignment(call, false, false, false);
    if (check_varargs(call, 0, 1)) {
      if (is_final_pass()) {
        if (call.vargs && call.vargs->size() > 0) {
          if (check_arg(call, Type::string, 0, true)) {
            auto &fmt_arg = *call.vargs->at(0);
            String &fmt = static_cast<String&>(fmt_arg);
            bpftrace_.time_args_.push_back(fmt.str);
          }
        } else {
          std::string fmt_default = "%H:%M:%S\n";
          bpftrace_.time_args_.push_back(fmt_default.c_str());
        }
      }
    }
  }
  else if (call.func == "strftime")
  {
    call.type = CreateTimestamp();
    if (check_varargs(call, 2, 2) && is_final_pass() &&
        check_arg(call, Type::string, 0, true) &&
        check_arg(call, Type::integer, 1, false))
    {
      auto &fmt_arg = *call.vargs->at(0);
      String &fmt = static_cast<String &>(fmt_arg);
      bpftrace_.strftime_args_.push_back(fmt.str);
    }
  }
  else if (call.func == "kstack") {
    check_stack_call(call, true);
  }
  else if (call.func == "ustack") {
    check_stack_call(call, false);
  }
  else if (call.func == "signal") {
    if (!feature_.has_helper_send_signal())
    {
      LOG(ERROR, call.loc, err_)
          << "BPF_FUNC_send_signal not available for your kernel version";
    }

    check_assignment(call, false, false, false);

    if (!check_varargs(call, 1, 1)) {
      return;
    }

    auto &arg = *call.vargs->at(0);
    if (arg.type.IsStringTy() && arg.is_literal)
    {
      auto sig = static_cast<String&>(arg).str;
      if (signal_name_to_num(sig) < 1) {
        LOG(ERROR, call.loc, err_) << sig << " is not a valid signal";
      }
    }
    else if (arg.type.IsIntTy() && arg.is_literal)
    {
      auto sig = static_cast<Integer&>(arg).n;
      if (sig < 1 || sig > 64) {
        LOG(ERROR, call.loc, err_)
            << std::to_string(sig)
            << " is not a valid signal, allowed range: [1,64]";
      }
    }
    else if(arg.type.type != Type::integer) {
      LOG(ERROR, call.loc, err_)
          << "signal only accepts string literals or integers";
    }

    for (auto &ap : *probe_->attach_points) {
      ProbeType type = probetype(ap->provider);
      if (ap->provider == "BEGIN" || ap->provider == "END") {
        LOG(ERROR, call.loc, err_) << call.func << " can not be used with \""
                                   << ap->provider << "\" probes";
      }
      else if (type == ProbeType::interval
          || type == ProbeType::software
          || type == ProbeType::hardware
          || type == ProbeType::watchpoint) {
        LOG(ERROR, call.loc, err_) << call.func << " can not be used with \""
                                   << ap->provider << "\" probes";
      }
    }
  }
  else if (call.func == "sizeof")
  {
    // sizeof() is a interesting builtin because the arguments can be either
    // an expression or a type. As a result, the only thing we'll check here
    // is that we have a single argument.
    check_nargs(call, 1);

    call.type = CreateUInt64();
  }
  else if (call.func == "strncmp") {
    if (check_nargs(call, 3)) {
      check_arg(call, Type::string, 0);
      check_arg(call, Type::string, 1);
      if (check_arg(call, Type::integer, 2, true)){
        Integer &size = static_cast<Integer&>(*call.vargs->at(2));
        if (size.n < 0)
          LOG(ERROR, call.loc, err_)
              << "Builtin strncmp requires a non-negative size";
      }
    }
    call.type = CreateUInt64();
  }
  else if (call.func == "override")
  {
    if (!feature_.has_helper_override_return())
    {
      LOG(ERROR, call.loc, err_)
          << "BPF_FUNC_override_return not available for your kernel version";
    }

    check_assignment(call, false, false, false);
    if (check_varargs(call, 1, 1))
    {
      check_arg(call, Type::integer, 0, false);
    }
    for (auto &attach_point : *probe_->attach_points)
    {
      ProbeType type = probetype(attach_point->provider);
      if (type != ProbeType::kprobe)
      {
        LOG(ERROR, call.loc, err_)
            << call.func << " can only be used with kprobes.";
      }
    }
  }
  else {
    LOG(ERROR, call.loc, err_) << "Unknown function: '" << call.func << "'";
    call.type = CreateNone();
  }
}

void SemanticAnalyser::check_stack_call(Call &call, bool kernel)
{
  call.type = CreateStack(kernel);
  if (check_varargs(call, 0, 2) && is_final_pass()) {
    StackType stack_type;
    if (call.vargs) {
      switch (call.vargs->size()) {
        case 0: break;
        case 1: {
          auto &arg = *call.vargs->at(0);
          // If we have a single argument it can be either
          // stack-mode or stack-size
          if (arg.type.IsStackModeTy())
          {
            if (check_arg(call, Type::stack_mode, 0, true))
              stack_type.mode = static_cast<StackMode&>(arg).type.stack_type.mode;
          }
          else
          {
            if (check_arg(call, Type::integer, 0, true))
              stack_type.limit = static_cast<Integer&>(arg).n;
          }
          break;
        }
        case 2: {
          if (check_arg(call, Type::stack_mode, 0, true)) {
            auto &mode_arg = *call.vargs->at(0);
            stack_type.mode = static_cast<StackMode&>(mode_arg).type.stack_type.mode;
          }

          if (check_arg(call, Type::integer, 1, true)) {
            auto &limit_arg = *call.vargs->at(1);
            stack_type.limit = static_cast<Integer&>(limit_arg).n;
          }
          break;
        }
        default:
          LOG(ERROR, call.loc, err_) << "Invalid number of arguments";
          break;
      }
    }
    if (stack_type.limit > MAX_STACK_SIZE)
    {
      LOG(ERROR, call.loc, err_)
          << call.func << "([int limit]): limit shouldn't exceed "
          << MAX_STACK_SIZE << ", " << stack_type.limit << " given";
    }
    call.type = CreateStack(kernel, stack_type);
    needs_stackid_maps_.insert(stack_type);
  }
}

void SemanticAnalyser::visit(Map &map)
{
  MapKey key;

  if (map.vargs) {
    size_t args_size = 0;
    bool needs_key_map = false;
    for (unsigned int i = 0; i < map.vargs->size(); i++){
      Expression * expr = map.vargs->at(i);
      expr->accept(*this);

      // Insert a cast to 64 bits if needed by injecting
      // a cast into the ast.
      if (expr->type.IsIntTy() && expr->type.size < 8)
      {
        std::string type = expr->type.IsSigned() ? "int64" : "uint64";
        Expression * cast = new ast::Cast(type, false, expr);
        cast->accept(*this);
        map.vargs->at(i) = cast;
        expr = cast;
      }
      else if (expr->type.IsCtxTy())
      {
        // map functions only accepts a pointer to a element in the stack
        LOG(ERROR, map.loc, err_) << "context cannot be used as a map key";
      }
      else if (expr->type.type == Type::tuple)
      {
        LOG(ERROR, map.loc, err_)
            << "tuple cannot be used as a map key. Try a multi-key associative"
               " array instead (eg `@map[$1, $2] = ...)`.";
      }
      else if (expr->type.IsStringTy())
      {
        needs_key_map = true;
      }
      args_size += expr->type.size;

      if (is_final_pass()) {
        if (expr->type.IsNoneTy())
          LOG(ERROR, expr->loc, err_) << "Invalid expression for assignment: ";
        if (expr->type.IsArrayTy())
          LOG(ERROR, expr->loc, err_)
              << "Using array as a map key is not supported (#1052)";

        SizedType keytype = expr->type;
        // Skip.IsSigned() when comparing keys to not break existing scripts
        // which use maps as a lookup table
        // TODO (fbs): This needs a better solution
        if (expr->type.IsIntTy())
          keytype = CreateUInt(keytype.size * 8);
        key.args_.push_back(keytype);
      }
    }
    max_key_size_ = std::max(max_key_size_, args_size);
    if (is_final_pass() && needs_key_map)
      bpftrace_.key_map_keys_.emplace(static_cast<Node *>(&map),
                                      bpftrace_.key_map_keys_.size());
  }

  if (is_final_pass()) {
    if (!map.skip_key_validation) {
      auto search = map_key_.find(map.ident);
      if (search != map_key_.end()) {
        if (search->second != key) {
          LOG(ERROR, map.loc, err_)
              << "Argument mismatch for " << map.ident << ": "
              << "trying to access with arguments: " << key.argument_type_list()
              << " when map expects arguments: "
              << search->second.argument_type_list();
        }
      }
      else {
        map_key_.insert({map.ident, key});
      }
    }
  }

  auto search_val = map_val_.find(map.ident);
  if (search_val != map_val_.end()) {
    map.type = search_val->second;
  }
  else {
    if (is_final_pass()) {
      LOG(ERROR, map.loc, err_) << "Undefined map: " << map.ident;
    }
    map.type = CreateNone();
  }
}

void SemanticAnalyser::visit(Variable &var)
{
  auto search_val = variable_val_.find(var.ident);
  if (search_val != variable_val_.end()) {
    var.type = search_val->second;
  }
  else {
    LOG(ERROR, var.loc, err_)
        << "Undefined or undeclared variable: " << var.ident;
    var.type = CreateNone();
  }
}

void SemanticAnalyser::visit(ArrayAccess &arr)
{
  arr.expr->accept(*this);
  arr.indexpr->accept(*this);

  SizedType &type = arr.expr->type;
  SizedType &indextype = arr.indexpr->type;

  if (is_final_pass()) {
    if (!((type.IsCtxTy() || type.IsArrayTy()) &&
          !type.GetElementTy()->IsNoneTy()))
    {
      LOG(ERROR, arr.loc, err_)
          << "The array index operator [] can only be used on arrays.";
      return;
    }

    if (indextype.IsIntTy() && arr.indexpr->is_literal)
    {
      Integer *index = static_cast<Integer *>(arr.indexpr);

      if ((size_t) index->n >= type.size)
        LOG(ERROR, arr.loc, err_)
            << "the index " << index->n
            << " is out of bounds for array of size " << type.size;
    }
    else {
      LOG(ERROR, arr.loc, err_) << "The array index operator [] only "
                                   "accepts literal integer indices.";
    }
  }

  arr.type = (type.IsCtxTy() | type.IsArrayTy()) ? *type.GetElementTy()
                                                 : CreateNone();
}

void SemanticAnalyser::visit(Binop &binop)
{
  binop.left->accept(*this);
  binop.right->accept(*this);
  Type &lhs = binop.left->type.type;
  Type &rhs = binop.right->type.type;
  bool lsign = binop.left->type.IsSigned();
  bool rsign = binop.right->type.IsSigned();

  if (is_final_pass()) {
    if ((lhs != rhs) &&
      // allow integer to cast pointer comparisons (eg, ptr != 0):
      !(lhs == Type::cast && rhs == Type::integer) &&
      !(lhs == Type::integer && rhs == Type::cast)) {
      LOG(ERROR, binop.left->loc + binop.right->loc, err_)
          << "Type mismatch for '" << opstr(binop) << "': comparing '" << lhs
          << "' with '" << rhs << "'";
    }
    // Follow what C does
    else if (lhs == Type::integer && rhs == Type::integer) {
      auto get_int_literal = [](const auto expr) -> long {
        return static_cast<ast::Integer*>(expr)->n;
      };
      auto left = binop.left;
      auto right = binop.right;

      // First check if operand signedness is the same
      if (lsign != rsign) {
        // Convert operands to unsigned if it helps make (lsign == rsign)
        //
        // For example:
        //
        // unsigned int a;
        // if (a > 10) ...;
        //
        // No warning should be emitted as we know that 10 can be
        // represented as unsigned int
        if (lsign && !rsign && left->is_literal && get_int_literal(left) >= 0) {
          lsign = false;
        }
        // The reverse (10 < a) should also hold
        else if (!lsign && rsign && right->is_literal && get_int_literal(right) >= 0) {
          rsign = false;
        }
        else {
          switch (binop.op) {
          case bpftrace::Parser::token::EQ:
          case bpftrace::Parser::token::NE:
          case bpftrace::Parser::token::LE:
          case bpftrace::Parser::token::GE:
          case bpftrace::Parser::token::LT:
          case bpftrace::Parser::token::GT:
            LOG(WARNING, binop.loc, out_)
                << "comparison of integers of different signs: '" << left->type
                << "' and '" << right->type << "'"
                << " can lead to undefined behavior";
            break;
          case bpftrace::Parser::token::PLUS:
          case bpftrace::Parser::token::MINUS:
          case bpftrace::Parser::token::MUL:
          case bpftrace::Parser::token::DIV:
          case bpftrace::Parser::token::MOD:
            LOG(WARNING, binop.loc, out_)
                << "arithmetic on integers of different signs: '" << left->type
                << "' and '" << right->type << "'"
                << " can lead to undefined behavior";
            break;
          default:
            break;
          }
        }
      }

      // Next, warn on any operations that require signed division.
      //
      // SDIV is not implemented for bpf. See Documentation/bpf/bpf_design_QA
      // in kernel sources
      if (binop.op == bpftrace::Parser::token::DIV ||
          binop.op == bpftrace::Parser::token::MOD) {
        // Convert operands to unsigned if possible
        if (lsign && left->is_literal && get_int_literal(left) >= 0)
          lsign = false;
        if (rsign && right->is_literal && get_int_literal(right) >= 0)
          rsign = false;

        // If they're still signed, we have to warn
        if (lsign || rsign) {
          LOG(WARNING, binop.loc, out_)
              << "signed operands for '" << opstr(binop)
              << "' can lead to undefined behavior "
              << "(cast to unsigned to silence warning)";
        }
      }
    }
    else if (!(lhs == Type::integer && rhs == Type::integer)
             && binop.op != Parser::token::EQ
             && binop.op != Parser::token::NE) {
      LOG(ERROR, binop.loc, err_)
          << "The " << opstr(binop)
          << " operator can not be used on expressions of types " << lhs << ", "
          << rhs;
    }
  }

  bool is_signed = lsign && rsign;
  switch (binop.op) {
    case bpftrace::Parser::token::LEFT:
    case bpftrace::Parser::token::RIGHT:
      is_signed = lsign;
      break;
    default:
      break;
  }

  binop.type = CreateInteger(64, is_signed);
}

void SemanticAnalyser::visit(Unop &unop)
{
  if (unop.op == Parser::token::INCREMENT ||
      unop.op == Parser::token::DECREMENT) {
    // Handle ++ and -- before visiting unop.expr, because these
    // operators should be able to work with undefined maps.
    if (!unop.expr->is_map && !unop.expr->is_variable) {
      LOG(ERROR, unop.loc, err_)
          << "The " << opstr(unop)
          << " operator must be applied to a map or variable";
    }
    if (unop.expr->is_map) {
      Map &map = static_cast<Map&>(*unop.expr);
      assign_map_type(map, CreateInt64());
    }
  }

  unop.expr->accept(*this);

  SizedType &type = unop.expr->type;
  if (is_final_pass() && !(type.IsIntTy()) &&
      !((type.IsCastTy() || type.IsCtxTy()) && unop.op == Parser::token::MUL))
  {
    LOG(ERROR, unop.loc, err_)
        << "The " << opstr(unop)
        << " operator can not be used on expressions of type '" << type << "'";
  }

  if (unop.op == Parser::token::MUL) {
    if (type.IsCastTy() || type.IsCtxTy())
    {
      if (type.is_pointer) {
        int cast_size;
        auto &intcasts = getIntcasts();
        auto k_v = intcasts.find(type.cast_type);
        if (k_v == intcasts.end() && bpftrace_.structs_.count(type.cast_type) == 0) {
          LOG(ERROR, unop.loc, err_)
              << "Unknown struct/union: '" << type.cast_type << "'";
          return;
        }
        if (k_v != intcasts.end()) {
          auto &v = k_v->second;
          unop.type = SizedType(Type::integer, std::get<0>(v), std::get<1>(v), k_v->first);
        } else {
          cast_size = bpftrace_.structs_[type.cast_type].size;
          unop.type = SizedType(type.type, cast_size, type.cast_type);
        }
        unop.type.is_tparg = type.is_tparg;
      }
      else if (type.is_kfarg)
      {
        // args->arg access, we need to push the args builtin
        // type further through the expression ladder
        unop.type = type;
      }
      else {
        LOG(ERROR, unop.loc, err_)
            << "Can not dereference struct/union of type '" << type.cast_type
            << "'. It is not a pointer.";
      }
    }
    else if (type.IsIntTy())
    {
      unop.type = CreateInteger(8 * type.size, type.IsSigned());
    }
  }
  else if (unop.op == Parser::token::LNOT) {
    unop.type = CreateUInt(type.size);
  }
  else {
    unop.type = CreateInteger(64, type.IsSigned());
  }
}

void SemanticAnalyser::visit(Ternary &ternary)
{
  ternary.cond->accept(*this);
  ternary.left->accept(*this);
  ternary.right->accept(*this);
  Type &cond = ternary.cond->type.type;
  Type &lhs = ternary.left->type.type;
  Type &rhs = ternary.right->type.type;
  if (is_final_pass()) {
    if (lhs != rhs) {
      LOG(ERROR, ternary.loc, err_)
          << "Ternary operator must return the same type: "
          << "have '" << lhs << "' and '" << rhs << "'";
    }
    if (cond != Type::integer)
      LOG(ERROR, ternary.loc, err_) << "Invalid condition in ternary: " << cond;
    if (lhs == Type::string)
      bpftrace_.str_map_keys_.emplace(static_cast<Node *>(&ternary),
                                      bpftrace_.str_map_keys_.size());
  }
  if (lhs == Type::string)
  {
    ternary.type = CreateString(bpftrace_.strlen_);
  }
  else if (lhs == Type::integer)
    ternary.type = CreateInteger(64, ternary.left->type.IsSigned());
  else if (lhs == Type::none)
    ternary.type = CreateNone();
  else {
    LOG(ERROR, ternary.loc, err_) << "Ternary return type unsupported " << lhs;
  }
}

void SemanticAnalyser::visit(If &if_block)
{
  if_block.cond->accept(*this);

  if (is_final_pass())
  {
    Type &cond = if_block.cond->type.type;
    if (cond != Type::integer)
      LOG(ERROR, if_block.loc, err_) << "Invalid condition in if(): " << cond;
  }

  accept_statements(if_block.stmts);

  if (if_block.else_stmts)
    accept_statements(if_block.else_stmts);
}

void SemanticAnalyser::visit(Unroll &unroll)
{
  unroll.expr->accept(*this);

  unroll.var = 0;

  if (auto *integer = dynamic_cast<Integer *>(unroll.expr))
  {
    unroll.var = integer->n;
  }
  else if (auto *param = dynamic_cast<PositionalParameter *>(unroll.expr))
  {
    if (param->ptype == PositionalParameterType::count)
    {
      unroll.var = bpftrace_.num_params();
    }
    else
    {
      std::string pstr = bpftrace_.get_param(param->n, param->is_in_str);
      if (is_numeric(pstr))
        unroll.var = std::stoll(pstr, nullptr, 0);
      else
        LOG(ERROR, unroll.loc, err_) << "Invalid positonal params: " << pstr;
    }
  }
  else
  {
    out_ << "Unsupported expression" << std::endl;
    abort();
  }

  if (unroll.var > 100)
  {
    LOG(ERROR, unroll.loc, err_) << "unroll maximum value is 100";
  }
  else if (unroll.var < 1)
  {
    LOG(ERROR, unroll.loc, err_) << "unroll minimum value is 1";
  }

  for (int i = 0; i < unroll.var; i++)
    accept_statements(unroll.stmts);
}

void SemanticAnalyser::visit(Jump &jump)
{
  switch (jump.ident)
  {
    case bpftrace::Parser::token::RETURN:
      // return can be used outside of loops
      break;
    case bpftrace::Parser::token::BREAK:
    case bpftrace::Parser::token::CONTINUE:
      if (!in_loop())
        LOG(ERROR, jump.loc, err_) << opstr(jump) << " used outside of a loop";
      break;
    default:
      LOG(ERROR, jump.loc, err_) << "Unknown jump: '" << opstr(jump) << "'";
  }
}

void SemanticAnalyser::visit(While &while_block)
{
  if (is_final_pass() && !feature_.has_loop())
  {
    LOG(WARNING, while_block.loc, out_)
        << "Kernel does not support bounded loops. Depending"
           " on LLVMs loop unroll to generate loadable code.";
  }

  while_block.cond->accept(*this);

  loop_depth_++;
  accept_statements(while_block.stmts);
  loop_depth_--;
}

void SemanticAnalyser::visit(FieldAccess &acc)
{
  // A field access must have a field XOR index
  assert((acc.field.size() > 0) != (acc.index >= 0));

  acc.expr->accept(*this);

  SizedType &type = acc.expr->type;
  if (type.type != Type::cast && type.type != Type::ctx &&
      type.type != Type::tuple)
  {
    if (is_final_pass())
    {
      std::string field;
      if (acc.field.size())
        field += "field '" + acc.field + "'";
      else
        field += "index " + std::to_string(acc.index);

      LOG(ERROR, acc.loc, err_) << "Can not access " << field
                                << " on expression of type '" << type << "'";
    }
    return;
  }

  if (type.is_kfarg)
  {
    auto it = ap_args_.find(acc.field);

    if (it != ap_args_.end())
      acc.type = it->second;
    else
      LOG(ERROR, acc.loc, err_) << "Can't find a field";
    return;
  }

  if (type.type == Type::tuple)
  {
    if (acc.index < 0)
    {
      LOG(ERROR, acc.loc, err_)
          << "Tuples must be indexed with a constant and non-negative integer";
      return;
    }

    bool valid_idx = static_cast<size_t>(acc.index) < type.tuple_elems.size();

    // We may not have inferred the full type of the tuple yet in early passes
    // so wait until the final pass.
    if (!valid_idx && is_final_pass())
      LOG(ERROR, acc.loc, err_)
          << "Invalid tuple index: " << acc.index << ". Found "
          << type.tuple_elems.size() << " elements in tuple.";

    if (valid_idx)
      acc.type = type.tuple_elems[acc.index];

    return;
  }

  if (type.is_pointer) {
    LOG(ERROR, acc.loc, err_)
        << "Can not access field '" << acc.field << "' on type '"
        << type.cast_type << "'. Try dereferencing it first, or using '->'";
    return;
  }
  if (bpftrace_.structs_.count(type.cast_type) == 0) {
    LOG(ERROR, acc.loc, err_)
        << "Unknown struct/union: '" << type.cast_type << "'";
    return;
  }

  std::map<std::string, FieldsMap> structs;

  if (type.is_tparg) {
    for (AttachPoint *attach_point : *probe_->attach_points) {
      if (probetype(attach_point->provider) != ProbeType::tracepoint)
      {
        // The args builtin can only be used with tracepoint
        // an error message is already generated in visit(Builtin)
        // just continue semantic analysis
        continue;
      }

      auto matches = bpftrace_.find_wildcard_matches(*attach_point);
      for (auto &match : matches) {
        std::string tracepoint_struct =
            TracepointFormatParser::get_struct_name(attach_point->target,
                                                    match);
        structs[tracepoint_struct] = bpftrace_.structs_[tracepoint_struct].fields;
      }
    }
  } else {
    structs[type.cast_type] = bpftrace_.structs_[type.cast_type].fields;
  }

  for (auto it : structs) {
    std::string cast_type = it.first;
    FieldsMap fields = it.second;
    if (fields.count(acc.field) == 0) {
      LOG(ERROR, acc.loc, err_)
          << "Struct/union of type '" << cast_type << "' does not contain "
          << "a field named '" << acc.field << "'";
    }
    else {
      acc.type = fields[acc.field].type;
      if (acc.expr->type.IsCtxTy() &&
          ((acc.type.IsCastTy() && !acc.type.is_pointer) ||
           acc.type.IsArrayTy()))
      {
        // e.g., ((struct bpf_perf_event_data*)ctx)->regs.ax
        // in this case, the type of FieldAccess to "regs" is Type::ctx
        acc.type.type = Type::ctx;
      }
      acc.type.is_internal = type.is_internal;
    }
  }
}

void SemanticAnalyser::visit(Cast &cast)
{
  cast.expr->accept(*this);

  bool is_ctx = cast.expr->type.IsCtxTy();
  auto &intcasts = getIntcasts();
  auto k_v = intcasts.find(cast.cast_type);
  int cast_size;

  if (k_v == intcasts.end() && bpftrace_.structs_.count(cast.cast_type) == 0) {
    LOG(ERROR, cast.loc, err_)
        << "Unknown struct/union: '" << cast.cast_type << "'";
    return;
  }

  if (cast.is_pointer) {
    if (k_v != intcasts.end() && is_ctx)
      LOG(ERROR, cast.loc, err_)
          << "Integer pointer casts are not supported for type: ctx";
    cast_size = sizeof(uintptr_t);
    cast.type = SizedType(is_ctx ? Type::ctx : Type::cast,
                          cast_size,
                          cast.cast_type);
    cast.type.is_pointer = cast.is_pointer;
    return;
  }

  if (k_v != intcasts.end()) {
    auto &v = k_v->second;
    cast.type = SizedType(Type::integer, std::get<0>(v), std::get<1>(v), k_v->first);

    auto rhs = cast.expr->type.type;
    // Casting Type::ctx to Type::integer is supported to access a
    // tracepoint's __data_loc field. See #990 and #770
    // In this case, the context information will be lost
    if (!(rhs == Type::integer || rhs == Type::cast || rhs == Type::ctx))
    {
      LOG(ERROR, cast.loc, err_)
          << "Casts are not supported for type: \"" << rhs << "\"";
    }

    return;
  }

  cast_size = bpftrace_.structs_[cast.cast_type].size;
  cast.type = SizedType(is_ctx ? Type::ctx : Type::cast,
                        cast_size,
                        cast.cast_type);
  cast.type.is_pointer = cast.is_pointer;
}

void SemanticAnalyser::visit(Tuple &tuple)
{
  auto &type = tuple.type;
  size_t total_size = 0;

  type.tuple_elems.clear();

  for (size_t i = 0; i < tuple.elems->size(); ++i)
  {
    Expression *elem = tuple.elems->at(i);
    elem->accept(*this);

    type.tuple_elems.emplace_back(elem->type);
    total_size += elem->type.size;
  }

  type.type = Type::tuple;
  type.size = total_size;
}

void SemanticAnalyser::visit(ExprStatement &expr)
{
  expr.expr->accept(*this);
}

void SemanticAnalyser::visit(AssignMapStatement &assignment)
{
  assignment.map->accept(*this);
  assignment.expr->accept(*this);

  assign_map_type(*assignment.map, assignment.expr->type);

  const std::string &map_ident = assignment.map->ident;
  auto type = assignment.expr->type.type;
  if (type == Type::cast)
  {
    std::string cast_type = assignment.expr->type.cast_type;
    std::string curr_cast_type = map_val_[map_ident].cast_type;
    if (curr_cast_type != "" && curr_cast_type != cast_type) {
      LOG(ERROR, assignment.loc, err_)
          << "Type mismatch for " << map_ident << ": "
          << "trying to assign value of type '" << cast_type
          << "' when map already contains a value of type '" << curr_cast_type
          << "''";
    }
    else {
      map_val_[map_ident].cast_type = cast_type;
      if (!assignment.expr->type.is_pointer)
      {
        // A pointer value is loaded to a register, not in the stack
        map_val_[map_ident].is_internal = true;
      }
    }
  }
  else if (type == Type::string)
  {
    auto map_size = map_val_[map_ident].size;
    auto expr_size = assignment.expr->type.size;
    if (map_size != expr_size)
    {
      std::stringstream buf;
      buf << "String size mismatch: " << map_size << " != " << expr_size << ".";
      if (map_size < expr_size)
      {
        buf << " The value may be truncated.";
        LOG(WARNING, assignment.loc, out_) << buf.str();
      }
      else
      {
        // bpf_map_update_elem() expects map_size-length value
        LOG(ERROR, assignment.loc, err_) << buf.str();
      }
    }
  }
  else if (type == Type::buffer)
  {
    auto map_size = map_val_[map_ident].size;
    auto expr_size = assignment.expr->type.size;
    if (map_size != expr_size)
    {
      std::stringstream buf;
      buf << "Buffer size mismatch: " << map_size << " != " << expr_size << ".";
      if (map_size < expr_size)
      {
        buf << " The value may be truncated.";
        LOG(WARNING, assignment.loc, out_) << buf.str();
      }
      else
      {
        // bpf_map_update_elem() expects map_size-length value
        LOG(ERROR, assignment.loc, err_) << buf.str();
      }
    }
  }
  else if (type == Type::ctx)
  {
    // bpf_map_update_elem() only accepts a pointer to a element in the stack
    LOG(ERROR, assignment.loc, err_) << "context cannot be assigned to a map";
  }
  else if (type == Type::tuple)
  {
    // Early passes may not have been able to deduce the full types of tuple
    // elements yet. So wait until final pass.
    if (is_final_pass())
    {
      const auto &map_type = map_val_[map_ident];
      const auto &expr_type = assignment.expr->type;
      if (map_type != expr_type)
      {
        LOG(ERROR, assignment.loc, err_) << "Tuple type mismatch: " << map_type
                                         << " != " << expr_type << ".";
      }
    }
  }

  if (is_final_pass())
  {
    if (type == Type::none)
      LOG(ERROR, assignment.expr->loc, err_)
          << "Invalid expression for assignment: " << type;
    if (type == Type::array)
      LOG(ERROR, assignment.expr->loc, err_)
          << "Assigning array is not supported (#1057)";
  }
}

void SemanticAnalyser::visit(AssignVarStatement &assignment)
{
  assignment.expr->accept(*this);

  std::string var_ident = assignment.var->ident;
  auto search = variable_val_.find(var_ident);
  assignment.var->type = assignment.expr->type;
  if (search != variable_val_.end()) {
    if (search->second.IsNoneTy())
    {
      if (is_final_pass()) {
        LOG(ERROR, assignment.loc, err_) << "Undefined variable: " + var_ident;
      }
      else {
        search->second = assignment.expr->type;
      }
    }
    else if (search->second.type != assignment.expr->type.type) {
      LOG(ERROR, assignment.loc, err_)
          << "Type mismatch for " << var_ident << ": "
          << "trying to assign value of type '" << assignment.expr->type
          << "' when variable already contains a value of type '"
          << search->second << "'";
    }
  }
  else {
    // This variable hasn't been seen before
    variable_val_.insert({var_ident, assignment.expr->type});
    assignment.var->type = assignment.expr->type;
  }

  if (assignment.expr->type.IsCastTy() || assignment.expr->type.IsCtxTy())
  {
    std::string cast_type = assignment.expr->type.cast_type;
    std::string curr_cast_type = variable_val_[var_ident].cast_type;
    if (curr_cast_type != "" && curr_cast_type != cast_type) {
      LOG(ERROR, assignment.loc, err_)
          << "Type mismatch for " << var_ident << ": "
          << "trying to assign value of type '" << cast_type
          << "' when variable already contains a value of type '"
          << curr_cast_type;
    }
    else {
      variable_val_[var_ident].cast_type = cast_type;
    }
  }
  else if (assignment.expr->type.IsStringTy())
  {
    auto var_size = variable_val_[var_ident].size;
    auto expr_size = assignment.expr->type.size;
    if (var_size != expr_size)
    {
      LOG(WARNING, assignment.loc, out_)
          << "String size mismatch: " << var_size << " != " << expr_size
          << (var_size < expr_size ? ". The value may be truncated."
                                   : ". The value may contain garbage.");
    }
  }
  else if (assignment.expr->type.IsBufferTy())
  {
    auto var_size = variable_val_[var_ident].size;
    auto expr_size = assignment.expr->type.size;
    if (var_size != expr_size)
    {
      LOG(WARNING, assignment.loc, out_)
          << "Buffer size mismatch: " << var_size << " != " << expr_size
          << (var_size < expr_size ? ". The value may be truncated."
                                   : ". The value may contain garbage.");
    }
  }
  else if (assignment.expr->type.type == Type::tuple)
  {
    // Early passes may not have been able to deduce the full types of tuple
    // elements yet. So wait until final pass.
    if (is_final_pass())
    {
      auto var_type = variable_val_[var_ident];
      auto expr_type = assignment.expr->type;
      if (var_type != expr_type)
      {
        LOG(ERROR, assignment.loc, err_) << "Tuple type mismatch: " << var_type
                                         << " != " << expr_type << ".";
      }
    }
  }

  if (is_final_pass())
  {
    auto &ty = assignment.expr->type.type;
    if (ty == Type::none)
      LOG(ERROR, assignment.expr->loc, err_)
          << "Invalid expression for assignment: " << ty;
    if (ty == Type::array)
      LOG(ERROR, assignment.expr->loc, err_)
          << "Assigning array is not supported (#1057)";
  }
}

void SemanticAnalyser::visit(Predicate &pred)
{
  pred.expr->accept(*this);
  if (is_final_pass() &&
      ((pred.expr->type.type != Type::integer) &&
       (!(pred.expr->type.is_pointer &&
          (pred.expr->type.IsCastTy() || pred.expr->type.IsCtxTy())))))
  {
    LOG(ERROR, pred.loc, err_)
        << "Invalid type for predicate: " << pred.expr->type.type;
  }
}

void SemanticAnalyser::visit(AttachPoint &ap)
{
  ap.provider = probetypeName(ap.provider);

  if (ap.provider == "kprobe" || ap.provider == "kretprobe") {
    if (ap.target != "")
      LOG(ERROR, ap.loc, err_) << "kprobes should not have a target";
    if (ap.func == "")
      LOG(ERROR, ap.loc, err_) << "kprobes should be attached to a function";
  }
  else if (ap.provider == "uprobe" || ap.provider == "uretprobe") {
    if (ap.target == "")
      LOG(ERROR, ap.loc, err_) << ap.provider << " should have a target";
    if (ap.func == "" && ap.address == 0)
      LOG(ERROR, ap.loc, err_)
          << ap.provider << " should be attached to a function and/or address";

    if (ap.provider == "uretprobe" && ap.func_offset != 0)
      LOG(ERROR, ap.loc, err_)
          << "uretprobes can not be attached to a function offset";

    auto paths = resolve_binary_path(ap.target, bpftrace_.pid());
    switch (paths.size())
    {
    case 0:
      LOG(ERROR, ap.loc, err_) << "uprobe target file '" << ap.target
                               << "' does not exist or is not executable";
      break;
    case 1:
      ap.target = paths.front();
      break;
    default:
      // If we are doing a PATH lookup (ie not glob), we follow shell
      // behavior and take the first match.
      if (ap.target.find("*") == std::string::npos)
      {
        LOG(WARNING, ap.loc, out_)
            << "attaching to uprobe target file '" << paths.front()
            << "' but matched " << std::to_string(paths.size()) << " binaries";
        ap.target = paths.front();
      }
      else
        LOG(ERROR, ap.loc, err_)
            << "uprobe target file '" << ap.target
            << "' must refer to a unique binary but matched "
            << std::to_string(paths.size());
    }
  }
  else if (ap.provider == "usdt") {
    bpftrace_.has_usdt_ = true;
    if (ap.func == "")
      LOG(ERROR, ap.loc, err_)
          << "usdt probe must have a target function or wildcard";

    if (ap.target != "") {
      auto paths = resolve_binary_path(ap.target, bpftrace_.pid());
      switch (paths.size())
      {
      case 0:
        LOG(ERROR, ap.loc, err_) << "usdt target file '" << ap.target
                                 << "' does not exist or is not executable";
        break;
      case 1:
        ap.target = paths.front();
        break;
      default:
        // If we are doing a PATH lookup (ie not glob), we follow shell
        // behavior and take the first match.
        if (ap.target.find("*") == std::string::npos)
        {
          LOG(WARNING, ap.loc, out_)
              << "attaching to usdt target file '" << paths.front()
              << "' but matched " << std::to_string(paths.size())
              << " binaries";
          ap.target = paths.front();
        }
        else
          LOG(ERROR, ap.loc, err_)
              << "usdt target file '" << ap.target
              << "' must refer to a unique binary but matched "
              << std::to_string(paths.size());
      }
    }

    if (bpftrace_.pid() > 0)
    {
      USDTHelper::probes_for_pid(bpftrace_.pid());
    }
    else if (ap.target != "")
    {
      USDTHelper::probes_for_path(ap.target);
    }
    else
    {
      LOG(ERROR, ap.loc, err_)
          << "usdt probe must specify at least path or pid to probe";
    }
  }
  else if (ap.provider == "tracepoint") {
    if (ap.target == "" || ap.func == "")
      LOG(ERROR, ap.loc, err_) << "tracepoint probe must have a target";
  }
  else if (ap.provider == "profile") {
    if (ap.target == "")
      LOG(ERROR, ap.loc, err_) << "profile probe must have unit of time";
    else if (ap.target != "hz" &&
             ap.target != "us" &&
             ap.target != "ms" &&
             ap.target != "s")
      LOG(ERROR, ap.loc, err_)
          << ap.target << " is not an accepted unit of time";
    if (ap.func != "")
      LOG(ERROR, ap.loc, err_)
          << "profile probe must have an integer frequency";
    else if (ap.freq <= 0)
      LOG(ERROR, ap.loc, err_)
          << "profile frequency should be a positive integer";
  }
  else if (ap.provider == "interval") {
    if (ap.target == "")
      LOG(ERROR, ap.loc, err_) << "interval probe must have unit of time";
    else if (ap.target != "ms" && ap.target != "s" && ap.target != "us" &&
             ap.target != "hz")
      LOG(ERROR, ap.loc, err_)
          << ap.target << " is not an accepted unit of time";
    if (ap.func != "")
      LOG(ERROR, ap.loc, err_)
          << "interval probe must have an integer frequency";
  }
  else if (ap.provider == "software") {
    if (ap.target == "")
      LOG(ERROR, ap.loc, err_)
          << "software probe must have a software event name";
    else {
      bool found = false;
      for (auto &probeListItem : SW_PROBE_LIST) {
        if (ap.target == probeListItem.path || (!probeListItem.alias.empty() && ap.target == probeListItem.alias)) {
          found = true;
          break;
        }
      }
      if (!found)
        LOG(ERROR, ap.loc, err_) << ap.target << " is not a software probe";
    }
    if (ap.func != "")
      LOG(ERROR, ap.loc, err_)
          << "software probe can only have an integer count";
    else if (ap.freq < 0)
      LOG(ERROR, ap.loc, err_) << "software count should be a positive integer";
  }
  else if (ap.provider == "watchpoint") {
    if (!ap.address)
      LOG(ERROR, ap.loc, err_)
          << "watchpoint must be attached to a non-zero address";
    if (ap.len != 1 && ap.len != 2 && ap.len != 4 && ap.len != 8)
      LOG(ERROR, ap.loc, err_) << "watchpoint length must be one of (1,2,4,8)";
    if (ap.mode.empty())
      LOG(ERROR, ap.loc, err_)
          << "watchpoint mode must be combination of (r,w,x)";
    std::sort(ap.mode.begin(), ap.mode.end());
    for (const char c : ap.mode) {
      if (c != 'r' && c != 'w' && c != 'x')
        LOG(ERROR, ap.loc, err_)
            << "watchpoint mode must be combination of (r,w,x)";
    }
    for (size_t i = 1; i < ap.mode.size(); ++i)
    {
      if (ap.mode[i - 1] == ap.mode[i])
        LOG(ERROR, ap.loc, err_) << "watchpoint modes may not be duplicated";
    }
    if (ap.mode == "rx" || ap.mode == "wx" || ap.mode == "rwx")
      LOG(ERROR, ap.loc, err_) << "watchpoint modes (rx, wx, rwx) not allowed";
  }
  else if (ap.provider == "hardware") {
    if (ap.target == "")
      LOG(ERROR, ap.loc, err_)
          << "hardware probe must have a hardware event name";
    else {
      bool found = false;
      for (auto &probeListItem : HW_PROBE_LIST) {
        if (ap.target == probeListItem.path || (!probeListItem.alias.empty() && ap.target == probeListItem.alias)) {
          found = true;
          break;
        }
      }
      if (!found)
        LOG(ERROR, ap.loc, err_) << ap.target + " is not a hardware probe";
    }
    if (ap.func != "")
      LOG(ERROR, ap.loc, err_)
          << "hardware probe can only have an integer count";
    else if (ap.freq < 0)
      LOG(ERROR, ap.loc, err_)
          << "hardware frequency should be a positive integer";
  }
  else if (ap.provider == "BEGIN" || ap.provider == "END") {
    if (ap.target != "" || ap.func != "")
      LOG(ERROR, ap.loc, err_) << "BEGIN/END probes should not have a target";
    if (is_final_pass()) {
      if (ap.provider == "BEGIN") {
        if (has_begin_probe_)
          LOG(ERROR, ap.loc, err_) << "More than one BEGIN probe defined";
        has_begin_probe_ = true;
      }
      if (ap.provider == "END") {
        if (has_end_probe_)
          LOG(ERROR, ap.loc, err_) << "More than one END probe defined";
        has_end_probe_ = true;
      }
    }
  }
  else if (ap.provider == "kfunc" || ap.provider == "kretfunc")
  {
#ifndef HAVE_BCC_KFUNC
    LOG(ERROR, ap.loc, err_)
        << "kfunc/kretfunc not available for your linked against bcc version.";
    return;
#endif

    bool supported = feature_.has_prog_kfunc() && bpftrace_.btf_.has_data();
    if (!supported)
    {
      LOG(ERROR, ap.loc, err_)
          << "kfunc/kretfunc not available for your kernel version.";
      return;
    }

    const auto& ap_map = bpftrace_.btf_ap_args_;
    auto it = ap_map.find(probe_->name());

    if (it != ap_map.end())
    {
      auto args = it->second;
      ap_args_.clear();
      ap_args_.insert(args.begin(), args.end());
    }
    else
    {
      LOG(ERROR, ap.loc, err_) << "Failed to resolve kfunc args.";
    }
  }
  else {
    LOG(ERROR, ap.loc, err_) << "Invalid provider: '" << ap.provider << "'";
  }
}

void SemanticAnalyser::visit(Probe &probe)
{
  // Clear out map of variable names - variables should be probe-local
  variable_val_.clear();
  probe_ = &probe;

  for (AttachPoint *ap : *probe.attach_points) {
    ap->accept(*this);
  }
  if (probe.pred) {
    probe.pred->accept(*this);
  }
  for (Statement *stmt : *probe.stmts) {
    stmt->accept(*this);
  }

}

void SemanticAnalyser::visit(Program &program)
{
  for (Probe *probe : *program.probes)
    probe->accept(*this);
}

int SemanticAnalyser::analyse()
{
  // Multiple passes to handle variables being used before they are defined
  std::string errors;

  for (pass_ = 1; pass_ <= num_passes_; pass_++) {
    root_->accept(*this);
    errors = err_.str();
    if (!errors.empty()) {
      out_ << errors;
      return pass_;
    }
  }

  return 0;
}

int SemanticAnalyser::create_maps(bool debug)
{
  uint32_t failed_maps = 0;
  auto is_invalid_map = [](int a) -> uint8_t { return a < 0 ? 1 : 0; };
  for (auto [map_name, type] : map_val_)
  {
    auto search_args = map_key_.find(map_name);
    if (search_args == map_key_.end())
    {
      out_ << "map key \"" << map_name << "\" not found" << std::endl;
      abort();
    }

    auto &key = search_args->second;

    if (debug)
    {
      bpftrace_.maps_[map_name] = std::make_unique<bpftrace::FakeMap>(map_name, type, key);
      bpftrace_.maps_[map_name]->id = bpftrace_.map_ids_.size();
      bpftrace_.map_ids_.push_back(map_name);
    }
    else
    {
      if (type.IsLhistTy())
      {
        // store lhist args to the bpftrace::Map
        auto map_args = map_args_.find(map_name);
        if (map_args == map_args_.end())
        {
          out_ << "map arg \"" << map_name << "\" not found" << std::endl;
          abort();
        }

        Expression &min_arg = *map_args->second.at(1);
        Expression &max_arg = *map_args->second.at(2);
        Expression &step_arg = *map_args->second.at(3);
        Integer &min = static_cast<Integer&>(min_arg);
        Integer &max = static_cast<Integer&>(max_arg);
        Integer &step = static_cast<Integer&>(step_arg);
        bpftrace_.maps_[map_name] = std::make_unique<bpftrace::Map>(
            map_name, type, key, min.n, max.n, step.n, bpftrace_.mapmax_);
        bpftrace_.maps_[map_name]->id = bpftrace_.map_ids_.size();
        bpftrace_.map_ids_.push_back(map_name);
        failed_maps += is_invalid_map(bpftrace_.maps_[map_name]->mapfd_);
      }
      else
      {
        bpftrace_.maps_[map_name] = std::make_unique<bpftrace::Map>(
            map_name, type, key, bpftrace_.mapmax_);
        bpftrace_.maps_[map_name]->id = bpftrace_.map_ids_.size();
        bpftrace_.map_ids_.push_back(map_name);
        failed_maps += is_invalid_map(bpftrace_.maps_[map_name]->mapfd_);
      }
    }
  }

  size_t max_zero_buffer_size_ = 0;

  for (auto [map_name, type] : variable_val_)
  {
    if (!needMemcpy(type))
      continue;

    MapKey key;
    if (debug)
    {
      bpftrace_.vars_[map_name] = std::make_unique<bpftrace::FakeMap>(map_name,
                                                                      type,
                                                                      key);
    }
    else
    {
      bpftrace_.vars_[map_name] = std::make_unique<bpftrace::Map>(
          map_name, type, key, 1, true);
    }
    failed_maps += is_invalid_map(bpftrace_.vars_[map_name]->mapfd_);
    max_zero_buffer_size_ = std::max(max_zero_buffer_size_, type.size);
  }

  for (StackType stack_type : needs_stackid_maps_) {
    // The stack type doesn't matter here, so we use kstack to force SizedType
    // to set stack_size.
    if (debug)
    {
      bpftrace_.stackid_maps_[stack_type] = std::make_unique<bpftrace::FakeMap>(
          CreateStack(true, stack_type));
    }
    else
    {
      bpftrace_.stackid_maps_[stack_type] = std::make_unique<bpftrace::Map>(
          CreateStack(true, stack_type));
      failed_maps += is_invalid_map(bpftrace_.stackid_maps_[stack_type]->mapfd_);
    }
  }

  if (debug)
  {
    if (needs_join_map_)
    {
      // join uses map storage as we'd like to process data larger than can fit on the BPF stack.
      std::string map_ident = "join";
      SizedType type = CreateJoin(bpftrace_.join_argnum_,
                                  bpftrace_.join_argsize_);
      MapKey key;
      bpftrace_.join_map_ = std::make_unique<bpftrace::FakeMap>(map_ident, type, key);
    }
    if (needs_elapsed_map_)
    {
      std::string map_ident = "elapsed";
      SizedType type = CreateUInt64();
      MapKey key;
      bpftrace_.elapsed_map_ =
          std::make_unique<bpftrace::FakeMap>(map_ident, type, key);
    }

    bpftrace_.perf_event_map_ = std::make_unique<bpftrace::FakeMap>(BPF_MAP_TYPE_PERF_EVENT_ARRAY);
  }
  else
  {
    if (needs_join_map_)
    {
      // join uses map storage as we'd like to process data larger than can fit on the BPF stack.
      std::string map_ident = "join";
      SizedType type = CreateJoin(bpftrace_.join_argnum_,
                                  bpftrace_.join_argsize_);
      MapKey key;
      bpftrace_.join_map_ = std::make_unique<bpftrace::Map>(
          map_ident, type, key, 1, true);
      failed_maps += is_invalid_map(bpftrace_.join_map_->mapfd_);
    }
    if (needs_elapsed_map_)
    {
      std::string map_ident = "elapsed";
      SizedType type = CreateUInt64();
      MapKey key;
      bpftrace_.elapsed_map_ =
          std::make_unique<bpftrace::Map>(map_ident, type, key, 1);
      failed_maps += is_invalid_map(bpftrace_.elapsed_map_->mapfd_);
    }
    bpftrace_.perf_event_map_ = std::make_unique<bpftrace::Map>(BPF_MAP_TYPE_PERF_EVENT_ARRAY);
    failed_maps += is_invalid_map(bpftrace_.perf_event_map_->mapfd_);
  }

  if (needs_fmtstr_map_)
  {
    std::string map_ident = "fmtstr";

    size_t printf_struct_size = sizeof(size_t) + max_fmtstr_args_size_;
    SizedType type = CreateString(printf_struct_size);
    MapKey key;
    if (debug)
      bpftrace_.fmtstr_map_ = std::make_unique<bpftrace::FakeMap>(map_ident,
                                                                  type,
                                                                  key);
    else
    {
      bpftrace_.fmtstr_map_ = std::make_unique<bpftrace::Map>(
          map_ident, type, key, 1, true);
    }
    failed_maps += is_invalid_map(bpftrace_.fmtstr_map_->mapfd_);
    max_zero_buffer_size_ = std::max(max_zero_buffer_size_, printf_struct_size);
  }

  if (!bpftrace_.str_map_keys_.empty())
  {
    std::string map_ident = "str";

    SizedType type = CreateString(bpftrace_.strlen_);
    MapKey key;
    if (debug)
      bpftrace_.str_map_ = std::make_unique<bpftrace::FakeMap>(map_ident,
                                                               type,
                                                               key);
    else
    {
      bpftrace_.str_map_ = std::make_unique<bpftrace::Map>(
          map_ident, type, key, bpftrace_.str_map_keys_.size(), true);
    }
    failed_maps += is_invalid_map(bpftrace_.str_map_->mapfd_);
    max_zero_buffer_size_ = std::max(max_zero_buffer_size_, bpftrace_.strlen_);
  }

  if (!bpftrace_.key_map_keys_.empty())
  {
    std::string map_ident = "key";

    SizedType type = CreateString(max_key_size_);
    MapKey key;
    if (debug)
      bpftrace_.key_map_ = std::make_unique<bpftrace::FakeMap>(map_ident,
                                                               type,
                                                               key);
    else
    {
      bpftrace_.key_map_ = std::make_unique<bpftrace::Map>(
          map_ident, type, key, bpftrace_.key_map_keys_.size(), true);
    }
    failed_maps += is_invalid_map(bpftrace_.key_map_->mapfd_);
    max_zero_buffer_size_ = std::max(max_zero_buffer_size_, max_key_size_);
  }

  if (!bpftrace_.buf_map_keys_.empty())
  {
    std::string map_ident = "buf";

    SizedType type = CreateString(max_buf_size_);
    MapKey key;
    if (debug)
      bpftrace_.buf_map_ = std::make_unique<bpftrace::FakeMap>(map_ident,
                                                               type,
                                                               key);
    else
    {
      bpftrace_.buf_map_ = std::make_unique<bpftrace::Map>(
          map_ident, type, key, bpftrace_.buf_map_keys_.size(), true);
    }
    failed_maps += is_invalid_map(bpftrace_.buf_map_->mapfd_);
    max_zero_buffer_size_ = std::max(max_zero_buffer_size_, max_buf_size_);
  }

  bpftrace_.zero_buffer_ = std::make_unique<std::vector<std::byte>>(
      max_zero_buffer_size_, std::byte(0));

  if (failed_maps > 0)
  {
    out_ << "Creation of the required BPF maps has failed." << std::endl;
    out_ << "Make sure you have all the required permissions and are not";
    out_ << " confined (e.g. like" << std::endl;
    out_ << "snapcraft does). `dmesg` will likely have useful output for";
    out_ << " further troubleshooting" << std::endl;
  }

  return failed_maps;
}

bool SemanticAnalyser::is_final_pass() const
{
  return pass_ == num_passes_;
}

bool SemanticAnalyser::check_assignment(const Call &call, bool want_map, bool want_var, bool want_map_key)
{
  if (want_map && want_var && want_map_key)
  {
    if (!call.map && !call.var && !call.key_for_map)
    {
      LOG(ERROR, call.loc, err_) << call.func
                                 << "() should be assigned to a map or a "
                                    "variable, or be used as a map key";
      return false;
    }
  }
  else if (want_map && want_var)
  {
    if (!call.map && !call.var)
    {
      LOG(ERROR, call.loc, err_)
          << call.func << "() should be assigned to a map or a variable";
      return false;
    }
  }
  else if (want_map && want_map_key)
  {
    if (!call.map && !call.key_for_map)
    {
      LOG(ERROR, call.loc, err_)
          << call.func
          << "() should be assigned to a map or be used as a map key";
      return false;
    }
  }
  else if (want_var && want_map_key)
  {
    if (!call.var && !call.key_for_map)
    {
      LOG(ERROR, call.loc, err_)
          << call.func
          << "() should be assigned to a variable or be used as a map key";
      return false;
    }
  }
  else if (want_map)
  {
    if (!call.map)
    {
      LOG(ERROR, call.loc, err_)
          << call.func << "() should be directly assigned to a map";
      return false;
    }
  }
  else if (want_var)
  {
    if (!call.var)
    {
      LOG(ERROR, call.loc, err_)
          << call.func << "() should be assigned to a variable";
      return false;
    }
  }
  else if (want_map_key)
  {
    if (!call.key_for_map)
    {
      LOG(ERROR, call.loc, err_)
          << call.func << "() should be used as a map key";
      return false;
    }
  }
  else
  {
    if (call.map || call.var || call.key_for_map)
    {
      LOG(ERROR, call.loc, err_)
          << call.func
          << "() should not be used in an assignment or as a map key";
      return false;
    }
  }
  return true;
}

bool SemanticAnalyser::check_nargs(const Call &call, size_t expected_nargs)
{
  std::stringstream err;
  std::vector<Expression*>::size_type nargs = 0;
  if (call.vargs)
    nargs = call.vargs->size();

  if (nargs != expected_nargs)
  {
    if (expected_nargs == 0)
      err << call.func << "() requires no arguments";
    else if (expected_nargs == 1)
      err << call.func << "() requires one argument";
    else
      err << call.func << "() requires " << expected_nargs << " arguments";

    err << " (" << nargs << " provided)";
    LOG(ERROR, call.loc, err_) << err.str();
    return false;
  }
  return true;
}

bool SemanticAnalyser::check_varargs(const Call &call, size_t min_nargs, size_t max_nargs)
{
  std::vector<Expression*>::size_type nargs = 0;
  std::stringstream err;
  if (call.vargs)
    nargs = call.vargs->size();

  if (nargs < min_nargs)
  {
    if (min_nargs == 1)
      err << call.func << "() requires at least one argument";
    else
      err << call.func << "() requires at least " << min_nargs << " arguments";

    err << " (" << nargs << " provided)";
    LOG(ERROR, call.loc, err_) << err.str();
    return false;
  }
  else if (nargs > max_nargs)
  {
    if (max_nargs == 0)
      err << call.func << "() requires no arguments";
    else if (max_nargs == 1)
      err << call.func << "() takes up to one argument";
    else
      err << call.func << "() takes up to " << max_nargs << " arguments";

    err << " (" << nargs << " provided)";
    LOG(ERROR, call.loc, err_) << err.str();
    return false;
  }

  return true;
}

bool SemanticAnalyser::check_arg(const Call &call, Type type, int arg_num, bool want_literal)
{
  if (!call.vargs)
    return false;

  auto &arg = *call.vargs->at(arg_num);
  if (want_literal && (!arg.is_literal || arg.type.type != type))
  {
    LOG(ERROR, call.loc, err_) << call.func << "() expects a " << type
                               << " literal (" << arg.type.type << " provided)";
    return false;
  }
  else if (is_final_pass() && arg.type.type != type) {
    LOG(ERROR, call.loc, err_)
        << call.func << "() only supports " << type << " arguments ("
        << arg.type.type << " provided)";
    return false;
  }
  return true;
}

bool SemanticAnalyser::check_symbol(const Call &call, int arg_num __attribute__((unused)))
{
  if (!call.vargs)
    return false;

  auto &arg = static_cast<String&>(*call.vargs->at(0)).str;

  std::string re = "^[a-zA-Z0-9./_-]+$";
  bool is_valid = std::regex_match(arg, std::regex(re));
  if (!is_valid)
  {
    LOG(ERROR, call.loc, err_)
        << call.func << "() expects a string that is a valid symbol (" << re
        << ") as input (\"" << arg << "\" provided)";
    return false;
  }

  return true;
}

/*
 * assign_map_type
 *
 *   Semantic analysis for assigning a value of the provided type
 *   to the given map.
 */
void SemanticAnalyser::assign_map_type(const Map &map, const SizedType &type)
{
  const std::string &map_ident = map.ident;
  auto search = map_val_.find(map_ident);
  if (search != map_val_.end()) {
    if (search->second.IsNoneTy())
    {
      if (is_final_pass()) {
        LOG(ERROR, map.loc, err_) << "Undefined map: " + map_ident;
      }
      else {
        search->second = type;
      }
    }
    else if (search->second.type != type.type) {
      LOG(ERROR, map.loc, err_)
          << "Type mismatch for " << map_ident << ": "
          << "trying to assign value of type '" << type
          << "' when map already contains a value of type '" << search->second;
    }
  }
  else {
    // This map hasn't been seen before
    map_val_.insert({map_ident, type});
    if (map_val_[map_ident].IsIntTy())
    {
      // Store all integer values as 64-bit in maps, so that there will
      // be space for any integer to be assigned to the map later
      map_val_[map_ident].size = 8;
    }
  }
}

void SemanticAnalyser::accept_statements(StatementList *stmts)
{
  for (size_t i = 0; i < stmts->size(); i++)
  {
    auto stmt = stmts->at(i);
    stmt->accept(*this);

    if (is_final_pass())
    {
      auto *jump = dynamic_cast<Jump *>(stmt);
      if (jump && i < (stmts->size() - 1))
      {
        LOG(WARNING, jump->loc, out_)
            << "All code after a '" << opstr(*jump) << "' is unreachable.";
      }
    }
  }
}

} // namespace ast
} // namespace bpftrace
