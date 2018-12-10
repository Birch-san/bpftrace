#pragma once

#include <string>

#include "mapkey.h"
#include "types.h"

namespace bpftrace {

class IMap {
public:
  virtual ~IMap() { }
  IMap() { }
  IMap(IMap &&) = default;
  IMap& operator=(IMap &&) = default;
  IMap(const IMap &) = default;
  IMap& operator=(const IMap &) = default;

  int mapfd_;
  std::string name_;
  SizedType type_;
  MapKey key_;

  // used by lhist(). TODO: move to separate Map object.
  int lqmin;
  int lqmax;
  int lqstep;
};

} // namespace bpftrace
