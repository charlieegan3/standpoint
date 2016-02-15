class Relation
  include Neo4j::ActiveRel

  from_class :Node
  to_class   :Node
  type 'REL'

  property :label
end
