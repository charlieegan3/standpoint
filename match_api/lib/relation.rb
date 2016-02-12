class Relation
  attr_accessor :origin_index, :origin_pos, :origin_tags, :origin_syntax, :origin_semantics
  attr_accessor :destination_index, :destination_pos, :destination_tags, :destination_syntax, :destination_semantics
  attr_accessor :label
  def initialize(origin_index, destination_index, origin_pos, destination_pos, label)
    @origin_index, @destination_index, @origin_pos, @destination_pos, @label =
    origin_index, destination_index, origin_pos, destination_pos, label

    @origin_syntax, @origin_semantics, @origin_tags = nil, nil, []
    @destination_syntax, @destination_semantics, @destination_tags = nil, nil, []
  end

  def origin_attributes
    {
      index: origin_index, pos: origin_pos,
      tags: origin_tags, syntax: origin_syntax,
      semantics: origin_semantics
    }
  end

  def destination_attributes
    {
      index: destination_index, pos: destination_pos,
      tags: destination_tags, syntax: destination_syntax,
      semantics: destination_semantics
    }
  end

  def add_origin_tags(tags)
    tags.each do |tag|
      if tag == tag.downcase && @origin_syntax.nil?
        @origin_syntax = tag
        next
      end

      if tag != tag.downcase && @origin_semantics.nil?
        @origin_semantics = tag
        next
      end

      @origin_tags << tag
    end
  end

  def add_destination_tags(tags)
    tags.each do |tag|
      if tag == tag.downcase && @destination_syntax.nil?
        @destination_syntax = tag
        next
      end

      if tag != tag.downcase && @destination_semantics.nil?
        @destination_semantics = tag
        next
      end

      @destination_tags << tag
    end
  end

  def print
    puts @origin_pos.to_s + " -> " + @label.to_s + " -> " + @destination_pos.to_s
  end

  def to_hash
    {
      origin: @origin_pos.inspect,
      label: @label.inspect,
      destination: @destination_pos.inspect,
    }
  end
end
