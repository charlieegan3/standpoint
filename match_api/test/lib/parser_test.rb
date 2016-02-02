require "test/unit"
require "tree"

require_relative "../../lib/parser"

class TestParser < Test::Unit::TestCase
  def test_prepare_sentence
    assert_equal(",word,", Parser.prepare_sentence("(word)"))
    assert_equal(",wo,rd,", Parser.prepare_sentence("(wo(rd)"))
  end

  def test_parse_tree
    parse = "(ROOT (NP (NN cat)))"
    assert_equal(["NP", ["NN", "cat"]], Parser.parse_tree(parse))
  end

  def test_build_tree
    parse = "(ROOT (S (NN cat) (VDB sat)))"

    tree = Tree::TreeNode.new("S", "S")
    tree << Tree::TreeNode.new("NN", "NN") << Tree::TreeNode.new("cat", "cat")
    tree << Tree::TreeNode.new("VDB", "VBD") << Tree::TreeNode.new("sat", "sat")

    assert_equal(tree, Parser.build_tree(Parser.parse_tree(parse)))
  end
end
