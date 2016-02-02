require_relative "../test_helper"

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

  def test_leaf_nodes
    root = build_tree(["root:content", [["c1:c1"],["c2:c2"],["c3:c3"]]])
    assert_equal(root.leaf_nodes.map(&:name), %w(c1 c2 c3))
    root = build_tree(
      ["root:content", [["c1:c1", [["c4:c4"]]],["c2:c2"],["c3:c3"]]]
    )
    assert_equal(%w(c4 c2 c3), root.leaf_nodes.map(&:name))
  end

  def test_str
    root = build_tree(["root:content",
        [["c1:c1", [["c4:c4", [["c5:c5"]]]]],["c2:c2"],["c3:c3"]]]
    )
    assert_equal(%w(c5 c2 c3), root.str)
  end

  def test_node_list
    root = build_tree(["root:content",
        [["c1:c1", [["c4:c4", [["c5:c5"]]]]],["c2:c2"],["c3:c3"]]]
    )
    assert_equal(%w(root c1 c4 c5 c2 c3), root.node_list.map(&:name))
  end

  def test_contains
    root = build_tree(["root:content", [["c1:c1"],["c2:c2"],["c3:c3"]]])
    assert_equal(true, root.contains?("c3"))
    assert_equal(false, root.contains?("c4"))
  end

  def test_index_at_parent
    root = build_tree(["root:content", [["c1:c1"],["c2:c2"],["c3:c3"]]])
    root << (c4 = Tree::TreeNode.new("c4", "c4"))
    assert_equal(3, c4.index_at_parent)
  end

  def test_match_component
    component = {string: "c1", original: "c1"}
    match = Tree::TreeNode.new("c1", "c1").match(component)
    assert_equal(true, match)

    component = {string: "c1", regex: /c2/, original: "c1"}
    match = Tree::TreeNode.new("c1", "c1").match(component)
    assert_equal(false, match)
  end

  def test_scan_basic_match
    root = build_tree(["root:content", [["c1:c1"],["c2:c2"],["c3:c3"]]])
    result = root.scan(Pattern.new("c1 c2 c3")).first
    assert_equal(root.children, result[:sub_matches].map { |s| s[:tree] })
    result = root.scan(Pattern.new("c1 c2")).first
    assert_equal(root.children[0..1], result[:sub_matches].map { |s| s[:tree] })
    result = root.scan(Pattern.new("c1 c3")).first
    assert_equal([root.children[0], root.children[2]],
                  result[:sub_matches].map { |s| s[:tree] })
  end

  def test_scan_nested_match
    root = Tree::TreeNode.new("root:content")
    root << (c1 = Tree::TreeNode.new("c1", "c1"))
    root << (c2 = Tree::TreeNode.new("c2", "c2"))
    root << Tree::TreeNode.new("c3", "c3") <<
            (c4 = Tree::TreeNode.new("c4", "c4"))

    result = root.scan(Pattern.new("c1 c2 c4")).first
    assert_equal([c1, c2, c4], result[:sub_matches].map { |s| s[:tree] })
    result = root.scan(Pattern.new("c1 c4")).first
    assert_equal([c1, c4], result[:sub_matches].map { |s| s[:tree] })
  end

  def test_scan_full_nested_match
    root = Tree::TreeNode.new("root:content")
    root << Tree::TreeNode.new("c1", "c1") << (c2 = Tree::TreeNode.new("c2", "c2"))
    root << (c3 = Tree::TreeNode.new("c3", "c3"))
    root << Tree::TreeNode.new("c4", "c4") <<
            (c5 = Tree::TreeNode.new("c5", "c5"))

    result = root.scan(Pattern.new("c2 c3 c5")).first
    assert_equal([c2, c3, c5], result[:sub_matches].map { |s| s[:tree] })
  end

  def test_scan_invalid_nested_match
    root = Tree::TreeNode.new("root:content")
    root << Tree::TreeNode.new("c1", "c1") << Tree::TreeNode.new("c2", "c2")

    result = root.scan(Pattern.new("c1 c2")).first
    assert_equal(nil, result)

    result = root.scan(Pattern.new("c1 c3")).first
    assert_equal(nil, result)
  end

  def test_scan_match_scores
    root = Tree::TreeNode.new("root:content")
    root << Tree::TreeNode.new("c1", "np")
    root << Tree::TreeNode.new("c2", "vp")
    root << Tree::TreeNode.new("c3", "vp")
    root << Tree::TreeNode.new("c4", "np")

    result = root.scan(Pattern.new("np np"))
    assert_equal(1, result.size)
    assert_equal(%w(c1 c4),
                 result.first[:sub_matches].map { |m| m[:tree].name })

    result = root.scan(Pattern.new("np vp np"))
    assert_equal(2, result.size)
    assert_equal([%w(c1 c2 c4), %w(c1 c3 c4)],
                 result.map { |r| r[:sub_matches].map { |m| m[:tree].name } })
  end
end
