require_relative 'edge'

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

  def is_verb?
    pos.match(/VB/)
  end

  def matching_edges(pattern, include_inbound, include_outbound)
    edges = []
    edges += inbound if include_inbound
    edges += outbound if include_outbound

    edges.reject { |e| (pattern =~ e.label).nil? }
  end

  def children
    matching_edges(//, false, true).map do |e|
      e.destination
    end.uniq
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

  def tree
    (descendants << self)
  end

  def scan(relation)
    if relation.origin_pos == /VB/
      outbound.each do |edge|
        return [self, edge.destination] if edge.match_relation?(relation)
      end
    else
      tree.each do |component|
        component.outbound.each do |edge|
          return [component, edge.destination] if edge.match_relation?(relation)
        end
      end
    end
    return nil
  end

  def to_hash(include_edges: false)
    hash = {
      word: word, pos: pos, lemma: lemma, index: index,
    }
    hash.merge!(inbound: inbound.map(&:to_hash)) if include_edges
    hash.merge!(outbound: outbound.map(&:to_hash)) if include_edges
    return hash
  end
end
