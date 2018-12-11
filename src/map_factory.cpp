#include "map_factory.h"
#include "types.h"
#include "map.h"
#include "mapkey.h"

namespace bpftrace {

int MapFactory::call_count_ = 0;

std::unique_ptr<IMap> MapFactory::constructMapForStoringBigStringsOffStack(
	uint64_t value_size
	) {
	return std::make_unique<Map>(
		"str_call" + MapFactory::call_count_++,
		SizedType(Type::str_call, value_size),
		MapKey()
	);
}

}