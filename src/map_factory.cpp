#include <memory>

#include "types.h"
#include "imap.h"
#include "map.h"
#include "mapkey.h"

namespace bpftrace {

int MapFactory::call_count_ = 0;

std::unique_ptr<IMap> MapFactory::constructMapForStoringBigStringsOffStack(uint64_t value_size) {
	std::string name = "str_call"+MapFactory::call_count_++;
	return std::static_pointer_cast<IMap>(
		std::make_unique<Map>(
			name,
			{Type::str_call, value_size},
			{} // zero-arg MapKey
		)
	);
}

}