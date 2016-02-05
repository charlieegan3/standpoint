require 'test_helper'
require_relative '../lib/node'
require_relative '../lib/edge'

class TestNode < Test::Unit::TestCase
  def test_descendants
    n1 = Node.new("word1", "pos", "lemma", 0)
    n2 = Node.new("word2", "pos", "lemma", 1)
    n3 = Node.new("word3", "pos", "lemma", 2)

    n1.outbound << Edge.new(n1, n2, "edge1")
    n2.outbound << Edge.new(n2, n3, "edge2")

    assert_equal([n1, n2, n3].reverse, n1.descendants)
    assert_equal([n2, n3].reverse, n2.descendants)
    assert_equal([n3], n3.descendants)
  end

  def test_ancestors
    n1 = Node.new("word1", "pos", "lemma", 0)
    n2 = Node.new("word2", "pos", "lemma", 1)
    n3 = Node.new("word3", "pos", "lemma", 2)

    n2.inbound << Edge.new(n1, n2, "edge1")
    n3.inbound << Edge.new(n2, n3, "edge2")

    assert_equal([n1], n1.ancestors)
    assert_equal([n1, n2], n2.ancestors)
    assert_equal([n1, n2, n3], n3.ancestors)
  end

  def test_graph
    n1 = Node.new("word1", "pos", "lemma", 0)
    n2 = Node.new("word2", "pos", "lemma", 1)
    n3 = Node.new("word3", "pos", "lemma", 2)
    n4 = Node.new("word4", "pos", "lemma", 3)

    n2.inbound << Edge.new(n1, n2, "edge1")
    n2.outbound << Edge.new(n2, n3, "edge2")
    n3.outbound << Edge.new(n3, n4, "edge3")

    assert_equal([n1, n2, n3, n4], n2.graph)
  end
end
