require_relative 'test_helper'
require_relative '../lib/node'
require_relative '../lib/graph'

class IntegrationTest < Test::Unit::TestCase
  def test_expected_sentences
    Dir["test/fixtures/*.json"].each do |fixture|
      fixture = JSON.parse(File.read(fixture))

      points = Graph.new(*fixture['parse']).nodes.map do |node|
        next unless point = node.point
        point.sort_by(&:index).map(&:word).join(" ")
      end.flatten.compact

      assert_equal(fixture['expected'], points)
    end
  end
end
