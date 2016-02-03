class Pattern
  attr_reader :components, :pattern_string

  def initialize(pattern_string)
    @pattern_string = pattern_string
    @components = translate(pattern_string)
  end

  private

  def translate(pattern_string)
    [].tap do |components|
      multi_component_substitute(pattern_string).split.each do |component|
        if t = translation(component)
          components << t
        else
          components << component
        end
      end
    end
  end

  def translation(component)
    regex = {
      "V" => /VB[^A-Z]?/,
      "v" => /VB[^A-Z]?/,
      "S-Quote" => /S|V[A-Z]+|NP/,
      "NP-Dative" => /NP/,
      "NP-Fulfilling" => /NP/,
      "PP-Conative" => /PP/,
      "ADV" => /RB/,
      "ADV-Middle" => /RB/,
      "ADVP" => /RB/,
      "ADVP-Middle" => /RB/,
      "ADJ" => /JJ/,
      "ADJ-Middle" => /JJ/,
      "ADJP" => /JJ/,
    }[component]
    {
      original: component,
      regex: regex,
      string: clean_component(component),
      tags: tags_for_component(component)
    }
  end

  def tags_for_component(component)
    component.scan(/(\.|_|-)((\w|-)+)/)
	  .flatten
      .reject { |t| t.length < 2 } || []
  end

  def clean_component(component)
    component.gsub(/(\.|_)((\w|-)+)/, '')
      .gsub(/\W+/, '')
  end

  def multi_component_substitute(string)
    string.gsub('V NP', 'VP')
  end
end
