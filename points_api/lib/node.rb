class Node
  include Neo4j::ActiveNode

  property :word
  property :part_of_speech
  property :lemma
  property :index

  has_many :out, :children, model_class: :Node, rel_class: :Relation
  has_many :in, :parents, model_class: :Node, rel_class: :Relation

  def self.string_for_create(options, sentence_index)
    attribute_string = options.map do |k,v|
      v = "\"#{v}\"" unless v.is_a? Integer
      "#{k} : #{v}"
    end.join(", ")

    "(s#{sentence_index}n#{options[:index]}:Node {#{attribute_string}})"
  end
end
