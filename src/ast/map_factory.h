#include <memory>
#include "imap.h"

namespace bpftrace {

class MapFactory {
public:
  static std::unique_ptr<IMap> constructMapForStoringBigStringsOffStack(uint64_t value_size);
private:
  static int call_count_;
  int call_id_;
};

}