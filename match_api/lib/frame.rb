class Frame
  attr_accessor :components, :pattern_string, :source, :example, :verb
  def initialize(raw_frame, verb)
    @pattern_string = raw_frame['syntax'].map do |c|
      c['value'] ? "#{c['name']}.#{c['value']}" : c['name']
    end.join(" ")
    @components = components_for_pattern
    @source = raw_frame['source']
    @example = raw_frame['examples'].first
    @verb = verb
  end

  def pos_pattern_string
    @components.map { |c| c[:pos] }.join(" ")
  end

  def components_for_pattern
    [].tap do |components|
      @pattern_string.split(/\s+/).each_with_index do |subpattern, index|
        components << build_component(subpattern, index)
      end
    end
  end

  def build_component(subpattern, index)
    tags = subpattern.scan(/(?:[A-Z]+)([\.\-_][\w-]+)/).flatten
    pos = subpattern.dup
    tags.each { |t| pos.gsub!(t, '') }
    tags.map! { |t| t.gsub(/^[\W_]+|[\W_]+$/, '') }
    return { index: index, string: subpattern, pos: pos, tags: tags }
  end

  def to_hash
    {
      string: @pattern_string,
      bare_frame: pos_pattern_string,
      missing_representation: 'not implemented',
      source: @source,
      example: @example,
      verb: @verb,
    }
  end
end
