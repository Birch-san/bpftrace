#pragma once

#include <tuple>
#include <string>
#include <vector>
#include <iostream>
#include <sys/utsname.h>
#include <sstream>
#include <signal.h>

namespace bpftrace {

typedef enum _USDT_TUPLE_ORDER_ { USDT_PATH_INDEX, USDT_PROVIDER_INDEX, USDT_FNAME_INDEX } usdt_probe_entry_enum;
typedef std::tuple<std::string, std::string, std::string> usdt_probe_entry;
typedef std::vector<usdt_probe_entry> usdt_probe_list;

class USDTHelper
{
public:
  static usdt_probe_entry find(
      int pid,
      const std::string &target,
      const std::string &provider,
      const std::string &name);
  static usdt_probe_list probes_for_provider(const std::string &provider);
  static usdt_probe_list probes_for_pid(int pid);
  static usdt_probe_list probes_for_path(const std::string &path);
  static void read_probes_for_pid(int pid);
  static void read_probes_for_path(const std::string &path);
};

// Hack used to suppress build warning related to #474
template <typename new_signature, typename old_signature>
new_signature cast_signature(old_signature func) {
#if __GNUC__ >= 8
_Pragma("GCC diagnostic push")
_Pragma("GCC diagnostic ignored \"-Wcast-function-type\"")
#endif
  return reinterpret_cast<new_signature>(func);
#if __GNUC__ >= 8
_Pragma("GCC diagnostic pop")
#endif
}

struct DeprecatedName
{
  std::string old_name;
  std::string new_name;
  bool show_warning = true;
};

static std::vector<DeprecatedName> DEPRECATED_LIST =
{
  { "stack", "kstack"},
  { "sym", "ksym"},
};

static std::vector<std::string> UNSAFE_BUILTIN_FUNCS =
{
  "system",
};

bool get_uint64_env_var(const ::std::string &str, uint64_t &dest);
std::string get_pid_exe(pid_t pid);
bool has_wildcard(const std::string &str);
std::vector<std::string> split_string(const std::string &str, char delimiter);
bool wildcard_match(const std::string &str, std::vector<std::string> &tokens, bool start_wildcard, bool end_wildcard);
std::vector<int> get_online_cpus();
std::vector<int> get_possible_cpus();
bool is_dir(const std::string& path);
std::tuple<std::string, std::string> get_kernel_dirs(const struct utsname& utsname);
std::vector<std::string> get_kernel_cflags(
    const char* uname_machine,
    const std::string& ksrc,
    const std::string& kobj);
std::string is_deprecated(std::string &str);
bool is_unsafe_func(const std::string &func_name);
std::string exec_system(const char* cmd);
std::string resolve_binary_path(const std::string& cmd);
void cat_file(const char *filename, size_t, std::ostream&);
std::string str_join(const std::vector<std::string> &list, const std::string &delim);

// trim from end of string (right)
inline std::string& rtrim(std::string& s)
{
  s.erase(s.find_last_not_of(" ") + 1);
  return s;
}

// trim from beginning of string (left)
inline std::string& ltrim(std::string& s)
{
  s.erase(0, s.find_first_not_of(" "));
  return s;
}

// trim from both ends of string (right then left)
inline std::string& trim(std::string& s)
{
  return ltrim(rtrim(s));
}

} // namespace bpftrace
