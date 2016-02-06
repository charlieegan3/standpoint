class Edge
  attr_accessor :origin, :destination, :label

  def initialize(origin, destination, label)
    @origin, @destination, @label = origin, destination, label
  end

  def print
    puts [
      origin.word + "(#{origin.pos})",
      label,
      destination.word + "(#{destination.pos})"
    ].join(" -> ")
  end

  def to_hash
    {
      label: label,
      origin: origin.to_hash(include_edges: false),
      destination: destination.to_hash(include_edges: false),
    }
  end
end
