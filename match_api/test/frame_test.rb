require_relative 'test_helper'
require_relative '../lib/frame'

class TestFrame < Test::Unit::TestCase
  def test_head_relations
    head, components = "b", %w(a b c d)
    f = Frame.new('a b c d')
    result = f.head_relations({ index: 1 })
    assert_equal([%w(a b), %w(b c), %w(b d)], result.map { |r| r.map { |c| c[:pos] } })

    head, components = "a", %w(a b c d)
    f = Frame.new('a b c d')
    result = f.head_relations({ index: 0 })
    assert_equal([%w(a b), %w(a c), %w(a d)], result.map { |r| r.map { |c| c[:pos] } })
  end

  def test_components_for_pattern
    f = Frame.new('a b c d')
    assert_equal(%w(a b c d), f.components_for_pattern.map { |c| c[:pos] })
  end

  def test_component_for_subpattern
    f = Frame.new('')

    result = f.component_for_subpattern('NP', 0)
    assert_equal('NP', result[:pos])

    result = f.component_for_subpattern('NP.tag', 1)
    assert_equal({ index: 1, string: 'NP.tag', pos: 'NP', tags: %w(tag) }, result)

    result = f.component_for_subpattern('ADJP-Result', 1)
    assert_equal({ index: 1, string: 'ADJP-Result', pos: 'ADJP', tags: %w(Result) }, result)

    result = f.component_for_subpattern('NP.co-agent', 1)
    assert_equal({ index: 1, string: 'NP.co-agent', pos: 'NP', tags: %w(co-agent) }, result)

    result = f.component_for_subpattern('PP.initial_location', 1)
    assert_equal({ index: 1, string: 'PP.initial_location', pos: 'PP', tags: %w(initial_location) }, result)

    result = f.component_for_subpattern('S_INF', 1)
    assert_equal({ index: 1, string: 'S_INF', pos: 'S', tags: %w(INF) }, result)
  end

  def test_head_component
    f = Frame.new('NP V NP')
    assert_equal('V', f.head[:string])

    f = Frame.new('Passive')
    assert_equal('Passive', f.head[:string])
  end

  def test_relations
    f = Frame.new('NP V NP')
    expected = [
      [/VB/, /subj/, /NNP|PRP|NN|NNS|DT|CD|JJR/],
      [/VB/, /dobj|iobj|xcomp/, /NN|NNS|PRP|NNP/]]
    assert_equal(expected, f.relations)
  end

  def test_connect
    f = Frame.new('NP V NP')
    assert_equal([/VB/, /subj/, /NNP|PRP|NN|NNS|DT|CD|JJR/], f.connect("NP", "V"))
  end
end
