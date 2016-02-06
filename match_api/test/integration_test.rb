require_relative 'test_helper'
require_relative '../lib/node'
require_relative '../lib/graph'

class IntegrationTest < Test::Unit::TestCase
  def test_expected_sentences
    Dir["test/fixtures/*.json"].each do |fixture|
      fixture = JSON.parse(File.read(fixture))

      points = Graph.new(*fixture['parse']).nodes.map do |node|
        node.point_strings
      end.flatten

      assert_equal(fixture['expected'], points)
    end
  end
end
