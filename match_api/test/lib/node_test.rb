require "test/unit"

require 'tree'

require_relative "../../lib/node"
require_relative "../../lib/pattern"


def build_tree(tree)
  node = Tree::TreeNode.new(*tree.first.split(":"))
  return node if tree.size == 1
  tree.last.map do |e|
    node << build_tree(e)
  end
  return node
end

class TestNode < Test::Unit::TestCase
  def test_remove_range
    root = build_tree(["root:content", [["c1:c1"],["c2:c2"],["c3:c3"]]])
    c3 = root.children.last
    root.remove_range!(0..1)
    assert_equal([c3], root.children)
  end
end
