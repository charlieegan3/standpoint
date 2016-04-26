# relation.rb
#
# This class extends the Neo4j::ActiveRel class and defines the structure of a
# dependency graph edge. These objects only have a single label attribute and
# connect two tokens nodes in the graphs.

class Relation
  include Neo4j::ActiveRel

  from_class :Node
  to_class   :Node
  type 'REL'

  property :label

  def self.string_for_create(from, relation, to, sentence_index)
    "(s#{sentence_index}#{from})-[s#{sentence_index.to_s+from+to+SecureRandom.hex[0..5]}:REL { label : \"#{relation}\" }]->(s#{sentence_index}#{to})"
  end
end
