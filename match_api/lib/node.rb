class Node
  attr_accessor :word, :pos, :lemma, :index, :inbound, :outbound

  def initialize(word, pos, lemma, index)
    @word, @pos, @lemma, @index = word, pos, lemma, index
    @inbound = []
    @outbound = []
  end

  def print
    [inbound, outbound].each(&:each).each(&:print)
  end

  def matching_edges(pattern, include_inbound, include_outbound)
    edges = []
    edges += inbound if include_inbound
    edges += outbound if include_outbound

    edges.reject { |e| (pattern =~ e.label).nil? }
  end

  def descendants(pattern=//)
    matching_edges(pattern, false, true).map do |e|
      [e.destination, e.destination.descendants(pattern)]
    end.flatten.uniq
  end

  def ancestors(pattern=//)
    matching_edges(pattern, true, false).map do |e|
      [e.origin, e.origin.ancestors(pattern)]
    end.flatten.uniq
  end

  def add_case
    return self if (nmod_egdes = matching_edges(/nmod:/, true, false)).size != 1
    return self if matching_edges(/case/, false, true).size != 0
    nmod = nmod_egdes.first.label.split(":").last
    case_node = Node.new(nmod, nmod.upcase, nmod, index-0.1)
    outbound << Edge.new(self, case_node, "case")
    case_node.inbound << Edge.new(self, case_node, "case")
    return [self, case_node]
  end

  def nmod_indexes
    outbound.map { |e| /nmod:/ =~ e.label }
      .each_with_index
      .map { |e, i| i if e }
      .compact
  end

  def nmod_points
    sets = []
    indexes = nmod_indexes
    return [] if indexes.size < 2
    indexes.size.times do
      set = outbound.dup
      set.delete_at(indexes.shift)
      sets << set
    end
    sets.map do |set|
      set.map do |e|
        [
          e.destination,
          e.destination.descendants(/^((?!^cc$|^conj:and).)*$/)
        ].flatten.reject { |n| n.pos.match(/CC|RB/) }.map(&:add_case)
      end.flatten << self
    end.reverse
  end

  def points
    [].tap do |points|
      points << (descendants << self)
      if nmod_indexes.size == 1
        points << (descendants(/^((?!^cc$|^conj:and).)*$/) << self)
      end
      nmod_points.map { |p| points << p }
    end.uniq
  end
end
