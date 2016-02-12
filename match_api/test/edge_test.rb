require_relative 'test_helper'
require_relative '../lib/node'

class TestEdge < Test::Unit::TestCase
  def test_match_relation
    relation = Relation.new(0, 1, /ori/, /des/, /lab/)
    n1 = Node.new('', 'ori', '', 0)
    n2 = Node.new('', 'des', '', 0)
    edge = Edge.new(n1, n2, 'lab')
    assert_true(edge.match_relation?(relation))
    relation = Relation.new(0, 1, /xxx/, /xxx/, /xxx/)
    assert_false(edge.match_relation?(relation))
  end
end
