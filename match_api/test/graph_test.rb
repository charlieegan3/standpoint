require_relative 'test_helper'
require_relative '../lib/graph'

class TestGraph < Test::Unit::TestCase
  def test_init
    tokens = [
      { 'word' => 'word1', 'pos' => 'pos', 'lemma' => 'lemma', 'index' => 1 },
      { 'word' => 'word2', 'pos' => 'pos', 'lemma' => 'lemma', 'index' => 2 },
      { 'word' => 'word3', 'pos' => 'pos', 'lemma' => 'lemma', 'index' => 3 },
    ]

    dependencies = [
      { 'dep' => 'relation2', 'governor' => 1, 'dependent' => 2 },
      { 'dep' => 'relation3', 'governor' => 1, 'dependent' => 3 },
    ]

    graph = Graph.new(tokens, dependencies)
    assert_equal(%w(word1 word2 word3), graph.nodes.map(&:word))
    assert_equal(%w(relation2 relation3), graph.edges.map(&:label))
    assert_equal(%w(word2 word3), graph.nodes.first.descendants.map(&:word))
    assert_equal(['word1'], graph.nodes.last.ancestors.map(&:word))
  end
end
