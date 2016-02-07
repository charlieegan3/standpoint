require_relative 'test_helper'
require_relative '../lib/node'

class TestEdge < Test::Unit::TestCase
  def test_match_relation
    relation = [/pat1/, /pat2/, /pat3/]
    n1 = Node.new('', 'pat1', '', 0)
    n2 = Node.new('', 'pat3', '', 0)
    edge = Edge.new(n1, n2, 'pat2')
    assert_true(edge.match_relation?(relation))
    relation = [/patx/, /patx/, /patx/]
    assert_false(edge.match_relation?(relation))
  end
end
