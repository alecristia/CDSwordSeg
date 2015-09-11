// xtree.cc

#include <vector>

#include "sym.h"
#include "xtree.h"
#include "utility.h"

template <typename tree_type>
void test() {

  tree_type* x1 = new tree_type("L1");
  tree_type* x2 = new tree_type("L2");
  tree_type* x3 = new tree_type("L3");
  tree_type* x4 = new tree_type("L4");
  tree_type* x5 = new tree_type("L5");

  x1->children.push_back(x2);
  x1->children.push_back(x3);
  x2->children.push_back(x4);
  x2->children.push_back(x5);

  std::cout << "*x1 = " << *x1 << std::endl;

  std::vector<symbol> ts;

  x1->terminals(ts);
  std::cout << "ts = " << ts << std::endl;

  delete x1;
}

int main(int argc, char** argv) {
  test<cattree_type>();
  test<catcounttree_type>();

}  // main()
