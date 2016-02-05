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

  def points
    [
      descendants << self,
      descendants(/^((?!^cc$|^conj:and).)*$/) << self,
    ].uniq
  end
end
