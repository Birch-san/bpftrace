#include <memory>
#include "imap.h"

namespace bpftrace {

class MapFactory {
public:
  static std::unique_ptr<IMap> constructMapForStoringBigStringsOffStack(int value_size);
private:
  static int call_count_;
  int call_id_;
}

}