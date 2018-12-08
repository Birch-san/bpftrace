#include "ast.h"

namespace bpftrace {
namespace ast {

class CallFactory {
public:
  Call* construct(
  	std::string &func,
  	ExpressionList *vargs = nullptr
  	);
};

}
}