class Node
  include Neo4j::ActiveNode

  property :word
  property :part_of_speech
  property :lemma
  property :index

  has_many :out, :children, model_class: :Node, rel_class: :Relation
  has_many :in, :parents, model_class: :Node, rel_class: :Relation
end
