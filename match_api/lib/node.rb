class Node
  attr_accessor :word, :pos, :lemma, :index, :inbound, :outbound

  def initialize(word, pos, lemma, index)
    @word, @pos, @lemma, @index = word, pos, lemma, index
    @inbound = []
    @outbound = []
  end

  def print
    inbound.each do |e|
      e.print
    end
    outbound.each do |e|
      e.print
    end
  end

  def descendants
    outbound.map do |e|
      e.destination.descendants
    end.flatten << self
  end

  def ancestors
    inbound.map do |e|
      e.origin.ancestors
    end.flatten << self
  end

  def graph
    nodes = [self]
    outbound.map do |e|
      nodes += e.destination.descendants
      nodes += e.destination.ancestors
    end
    inbound.map do |e|
      nodes += e.origin.descendants
      nodes += e.origin.ancestors
    end
    return nodes.uniq.sort_by(&:index)
  end
end
