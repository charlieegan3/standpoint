require_relative 'relation'

class Frame
  attr_accessor :components, :pattern_string
  def initialize(pattern_string)
    @pattern_string = pattern_string
    @components = components_for_pattern
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

  def query
    relations = []
    frame_relations = Frame.relations(pos_pattern_string)
    puts "Missing: " + pos_pattern_string if frame_relations.empty?
    frame_relations.each do |relation|
      relation.add_origin_tags(@components[relation.origin_index][:tags])
      relation.add_destination_tags(@components[relation.destination_index][:tags])
      relations << relation
    end
  end

  def to_hash
    { pattern: @pattern_string, components: @components }
  end

  def self.relations(pos_pattern_string)
    {
      'NP VERB NP' => [
        Relation.new(1, 0, /VB/, /NN|PRP/, /subj/),
        Relation.new(1, 2, /VB/, /NN|PRP/, /dobj/),
      ],
      'NP VERB NP PREP NP' => [
        Relation.new(1, 0, /VB/, /NN|PRP/, /subj/),
        Relation.new(1, 2, /VB/, /NN|PRP/, /dobj/),
        Relation.new(1, 4, /VB/, /NN/, /nmod/),
        Relation.new(4, 3, /NN/, /IN/, /case/),
      ],
      'NP VERB PREP NP' => [
        Relation.new(1, 0, /VB/, /NN|PRP/, /subj/),
        Relation.new(1, 3, /VB/, /NN/, /nmod/),
        Relation.new(3, 2, /VB/, /IN/, /case/),
      ],
      'NP VERB' => [
        Relation.new(1, 0, /VB/, /NN|PRP/, /subj/),
      ],
      'NP VERB NP NP' => [
        Relation.new(1, 0, /VB/, /NN|PRP/, /subj/),
        Relation.new(1, 2, /VB/, /NN|PRP/, /dobj/),
        Relation.new(1, 3, /VB/, /VB/, /xcomp/),
      ],
      'NP VERB PREP NP NP' => [
        Relation.new(1, 0, /VB/, /NN|PRP/, /subj/),
        Relation.new(1, 3, /VB/, /NN/, /nmod/),
        Relation.new(3, 2, /NN/, /TO/, /case/),
        Relation.new(1, 4, /VB/, /NN|PRP/, /dobj/),
      ],
      'NP VERB ADV' => [
        Relation.new(1, 0, /VB/, /NN|PRP/, /subj/),
        Relation.new(1, 2, /VB/, /RB/, /advmod/),
      ],
      'NP VERB PREP NP PREP NP' => [
        Relation.new(1, 0, /VB/, /NN|PRP/, /subj/),
        Relation.new(1, 3, /VB/, /PRP/, /nmod/),
        Relation.new(3, 2, /PRP/, /IN/, /case/),
        Relation.new(1, 5, /VB/, /NN/, /nmod/),
        Relation.new(5, 1, /NN/, /IN/, /case/),
      ],
    }[pos_pattern_string] || []
  end
end
