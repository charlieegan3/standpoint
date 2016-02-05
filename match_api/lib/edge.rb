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
end
