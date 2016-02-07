class Frame
  attr_accessor :components, :pattern
  def initialize(pattern_string)
    @pattern_string = pattern_string
    @components = components_for_pattern
  end

  def head
    @components.select { |c| c[:string] == "V" }.first || @components.first
  end

  def relations
    head_relations(head).map do |relation|
      connect(relation.first[:pos], relation.last[:pos])
    end
  end

  def connect(component1, component2)
    if component1 == "NP"
      return [/NNP|PRP|NN|NNS|DT|CD|JJR/, /subj/, /VB/] if component2 == "V"
    elsif component1 == "V"
      return [/VB/, /dobj|iobj/, /NN|NNS|PRP|NNP|JJ/] if component2 == "NP"
      return [/VB/, /xcomp|ccomp|advcl/, /VB/] if component2 == "S"
      return [/VB/, /xcomp|ccomp|advcl/, /VB/] if component2 == "S_INF"
      return [/VB/, /xcomp|ccomp|advcl/, /VB/] if component2 == "S_ING"
      return [/VB/, /nmod/, /NN|NNS|NNP|PRP|CD|JJ/] if component2 == "PP"
      return [/VB/, /advmod/, /RB|NN/] if component2 == "ADV"
      return [/VB/, /advmod/, /RB/] if component2 == "ADVP"
      return [/VB/, /ccomp|dep/, /VB/] if component2 == "S-Quote"
    end
  end

  def components_for_pattern
    [].tap do |components|
      @pattern_string.split(/\s+/).each_with_index do |subpattern, index|
        components << component_for_subpattern(subpattern, index)
      end
    end
  end

  def component_for_subpattern(subpattern, index)
    tags = subpattern.scan(/(?:[A-Z]+)([\.\-_][\w-]+)/).flatten
    pos = subpattern.dup
    tags.each { |t| pos.gsub!(t, '') }
    tags.map! { |t| t.gsub(/^[\W_]+|[\W_]+$/, '') }
    return { index: index, string: subpattern, pos: pos, tags: tags }
  end

  def head_relations(head)
    [].tap do |pairs|
      for i in 0...@components.size
        for j in i+1...@components.size
          if (pair = [@components[i], @components[j]]).map { |c| c[:index] }.include? head[:index]
            pairs << pair
          end
        end
      end
    end
  end
end
