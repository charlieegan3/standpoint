require_relative 'relation'

class Frame
  attr_accessor :components, :pattern_string, :source, :example, :verb
  def initialize(pattern_string, raw_frame, verb)
    @pattern_string = pattern_string
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
    {
      string: @pattern_string,
      bare_frame: pos_pattern_string,
      missing_representation: Frame.relations(pos_pattern_string).empty?,
      source: @source,
      example: @example,
      verb: @verb,
    }
  end

  def self.relations(pos_pattern_string)
    {
      'NP VERB NP' => [
        Relation.new(1, 0, /VB/, /NN|PRP/, /subj/),
        Relation.new(1, 2, /VB/, /NN|PRP/, /dobj|nmod/),
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
        Relation.new(3, 2, /NN/, /IN/, /case/),
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
      'NP VERB NP PREP NP PREP NP' => [
        Relation.new(1, 0, /VB/, /NN|PRP/, /subj/),
        Relation.new(1, 2, /VB/, /NN/, /dobj/),
        Relation.new(1, 4, /VB/, /NN|JJ/, /nmod/),
        Relation.new(1, 6, /VB/, /NN|JJ/, /nmod/),
        Relation.new(4, 3, /VB/, /IN/, /case/),
        Relation.new(6, 5, /VB/, /IN/, /case/),
      ],
      'PREP NP VERB NP' => [
        Relation.new(1, 0, /NN/, /IN/, /case/),
        Relation.new(2, 1, /VB/, /NN/, /nmod/),
        Relation.new(2, 3, /VB/, /NN/, /dobj/),
      ],
      'LEX VERB NP PREP NP' => [
        Relation.new(1, 0, /VB/, /EX/, /expl/),
        Relation.new(1, 2, /VB/, /NN/, /dobj/),
        Relation.new(1, 4, /VB/, /NN/, /nmod/),
        Relation.new(4, 3, /NN/, /IN/, /case/),
      ],
      'NP VERB NP LEX' => [
        Relation.new(1, 0, /VB/, /NN/, /nsubj/),
        Relation.new(1, 2, /VB/, /NN/, /dobj/),
        Relation.new(1, 3, /VB/, /RB/, /advmod/),
      ],
      'LEX VERB PREP NP NP' => [
        Relation.new(1, 0, /VB/, /EX/, /expl/),
        Relation.new(1, 3, /VB/, /NN/, /nmod/),
        Relation.new(3, 4, /NN/, /NN/, /dep/),
      ],
      'NP LEX VERB NP' => [
        Relation.new(2, 1, /VB/, /NN/, /nsubj/),
        Relation.new(2, 3, /VB/, /NN/, /dobj/),
      ],
      'NP VERB ADV PREP NP' => [
        Relation.new(1, 0, /VB/, /NN/, /nsubj/),
        Relation.new(1, 2, /VB/, /RB/, /advmod/),
        Relation.new(1, 4, /VB/, /NN/, /nmod/),
        Relation.new(4, 3, /NN/, /IN/, /case/),
      ],
      'NP VERB ADV LEX' => [
        Relation.new(1, 0, /VB/, /NN/, /nsubj/),
        Relation.new(1, 2, /VB/, /RB/, /advmod/),
        Relation.new(1, 3, /VB/, /RB/, /advmod/),
      ],
      'NP VERB NP LEX NP' => [
        Relation.new(1, 0, /VB/, /NN|PRP/, /nsubj/),
        Relation.new(1, 2, /VB/, /NN|PRP/, /dobj/),
        Relation.new(1, 4, /VB/, /NN|JJ/, /advcl/),
        Relation.new(4, 1, /NN|JJ/, /IN/, /mark/),
      ],
      'NP VERB LEX' => [
        Relation.new(1, 0, /VB/, /NN/, /nsubj/),
        Relation.new(1, 2, /VB/, /RB/, /advmod/),
      ],
      'NP VERB NP NP PREP NP' => [ #parses for this frame vary
        Relation.new(1, 0, /VB/, /NN/, /nsubj/),
        Relation.new(1, 2, /VB/, /NN/, /dobj/),
        Relation.new(1, 3, /VB/, /NN|RP/, /compound|xcomp|nmod/),
        Relation.new(1, 5, /VB/, /NN/, /nmod/),
      ],
      'NP VERB LEX NP' => [
        Relation.new(1, 0, /VB/, /NN/, /nsubj/),
        Relation.new(1, 3, /VB/, /NN/, /nmod/),
        Relation.new(3, 2, /NN/, /IN/, /case/),
      ],
      'NP VERB LEX ADV' => [
        Relation.new(1, 0, /VB/, /NN/, /nsubj/),
        Relation.new(1, 2, /VB/, /RB/, /advmod/),
        Relation.new(1, 3, /VB/, /RB/, /advmod/),
      ],
      'LEX VERB NP' => [
        Relation.new(1, 0, /VB/, /EX/, /expl/),
        Relation.new(1, 2, /VB/, /NN/, /dobj/),
      ],
      'NP VERB PREP NP ADV' => [
        Relation.new(1, 0, /VB/, /NN/, /nsubj/),
        Relation.new(1, 3, /VB/, /NN/, /nmod/),
        Relation.new(3, 2, /NN/, /IN/, /case/),
        Relation.new(1, 4, /VB/, /RB/, /advmod/),
      ],
      'NP LEX NP VERB' => [
        Relation.new(3, 0, /VB/, /NN/, /nsubj/),
        Relation.new(0, 2, /NN/, /NN/, /nmod/),
        Relation.new(2, 1, /NN/, /IN/, /case/),
      ],
    }[pos_pattern_string] || []
  end
end
