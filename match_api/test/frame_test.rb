require_relative 'test_helper'
require_relative '../lib/frame'

class TestFrame < Test::Unit::TestCase
  def test_components_for_pattern
    f = Frame.new('a b c d')
    assert_equal(%w(a b c d), f.components_for_pattern.map { |c| c[:pos] })
  end

  def test_build_component
    f = Frame.new('')

    result = f.build_component('NP', 0)
    assert_equal('NP', result[:pos])

    result = f.build_component('NP.tag', 1)
    assert_equal({ index: 1, string: 'NP.tag', pos: 'NP', tags: %w(tag) }, result)

    result = f.build_component('ADJP-Result', 1)
    assert_equal({ index: 1, string: 'ADJP-Result', pos: 'ADJP', tags: %w(Result) }, result)

    result = f.build_component('NP.co-agent', 1)
    assert_equal({ index: 1, string: 'NP.co-agent', pos: 'NP', tags: %w(co-agent) }, result)

    result = f.build_component('PP.initial_location', 1)
    assert_equal({ index: 1, string: 'PP.initial_location', pos: 'PP', tags: %w(initial_location) }, result)

    result = f.build_component('S_INF', 1)
    assert_equal({ index: 1, string: 'S_INF', pos: 'S', tags: %w(INF) }, result)
  end

  def test_relations
    f = Frame.new('NP.syntax VERB.Semantic NP')
    result = f.query
    assert_equal([/NN|PRP/, /NN|PRP/], result.map(&:destination_pos))
    assert_equal([/VB/, /VB/], result.map(&:origin_pos))
    assert_equal(result.first.destination_syntax, 'syntax')
    assert_equal(result.first.origin_semantics, 'Semantic')
  end
end
