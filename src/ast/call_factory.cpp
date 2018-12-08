#include "call_factory.h"

namespace bpftrace {
namespace ast {

Call* CallFactory::construct(
	std::string &func,
	ExpressionList *vargs = nullptr
	) {
	if (func == "str") {
		return new StrCall(
			std::forward(func),
			std::forward(vargs)
			);
	}
	return new Call(
		std::forward(func),
		std::forward(vargs)
		);
}

}
}