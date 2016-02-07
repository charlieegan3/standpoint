require_relative 'test_helper'
require_relative '../lib/node'

class TestNode < Test::Unit::TestCase
  def test_descendants
    n1 = Node.new("word1", "pos", "lemma", 0)
    n2 = Node.new("word2", "pos", "lemma", 1)
    n3 = Node.new("word3", "pos", "lemma", 2)

    n1.outbound << Edge.new(n1, n2, "edge1")
    n2.outbound << Edge.new(n2, n3, "edge2")

    assert_equal([n2, n3], n1.descendants)
    assert_equal([n3], n2.descendants)
    assert_equal([], n3.descendants)
  end

  def test_ancestors
    n1 = Node.new("word1", "pos", "lemma", 0)
    n2 = Node.new("word2", "pos", "lemma", 1)
    n3 = Node.new("word3", "pos", "lemma", 2)

    n2.inbound << Edge.new(n1, n2, "edge1")
    n3.inbound << Edge.new(n2, n3, "edge2")

    assert_equal([], n1.ancestors)
    assert_equal([n1], n2.ancestors)
    assert_equal([n1, n2].reverse, n3.ancestors)
  end

  def test_add_case
    node = Node.new("word", "pos", "lemma", 0)
    node.inbound << Edge.new(nil, node, "nmod:to")

    assert_equal(nil, node.outbound.map(&:label).first)
    node.add_case
    assert_equal('case', node.outbound.map(&:label).first)
    assert_equal('to', node.outbound.first.destination.word)
  end

  def test_nmod_indexes
    node = Node.new("word", "pos", "lemma", 0)

    node.outbound << Edge.new(node, nil, "label")
    node.outbound << Edge.new(node, nil, "nmod:to")
    node.outbound << Edge.new(node, nil, "label")
    node.outbound << Edge.new(node, nil, "nmod:to")

    assert_equal([1, 3], node.nmod_indexes)
  end

  def test_nmod_points
    node = Node.new("word", "pos", "lemma", 0)
    nmod1 = Node.new("nmod1", "pos", "lemma", 1)
    nmod2 = Node.new("nmod2", "pos", "lemma", 2)

    node.outbound << Edge.new(node, nmod1, "nmod:to")
    node.outbound << Edge.new(node, nmod2, "nmod:to")
    nmod1.inbound << Edge.new(node, nmod1, "nmod:to")
    nmod2.inbound << Edge.new(node, nmod2, "nmod:to")

    points = node.nmod_points.map { |p| p.sort_by(&:index).map(&:word).join(" ") }

    assert_equal(['word to nmod1', 'word to nmod2'], points)
  end
end
