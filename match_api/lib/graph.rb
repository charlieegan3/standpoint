require_relative 'node'

class Graph
  attr_accessor :nodes, :edges

  def initialize(tokens, dependencies)
    nodes = tokens.map { |t| [t['word'], t['pos'], t['lemma'], t['index'].to_i-1] }
    edges = dependencies.map {|d| [d['dep'], d['governor'].to_i-1, d['dependent'].to_i-1] }

    blacklist = %w(ROOT)
    edges.reject! { |l,g,d| blacklist.include?(l) }

    @nodes = nodes.map { |w,p,l,i| Node.new(w, p, l, i) }
    @edges = edges.map do |l,g,d|
      Edge.new(@nodes[g], @nodes[d], l).tap do |edge|
        @nodes[g].outbound << edge
        @nodes[d].inbound << edge
      end
    end
  end
end
