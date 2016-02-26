class Neo4jClient
  def initialize(url)
    Neo4j::Session.open(:server_db, url)
  end

  def sentence_query_components(tokens, dependencies, sentence_index)
    nodes = tokens.map do |t|
      [t['word'], t['pos'], t['lemma'], t['index'].to_i-1]
    end
    relations = dependencies.uniq.map do |d|
      [d['dep'], d['governor'].to_i-1, d['dependent'].to_i-1]
    end
    relations.reject! { |l, g, d| g == d || l == 'ROOT'}

    nodes.map! do |word, pos, lemma, index|
      options = { word: word, part_of_speech: pos, lemma: lemma, index: index }
      Node.string_for_create(options, sentence_index)
    end
    query_string = "#{nodes.join(", ")}"

    relations.map! do |label, parent_index, child_index|
      Relation.string_for_create("n#{parent_index}", label, "n#{child_index}", sentence_index)
    end
    query_string += ", #{relations.join(", ")}"
  end

  def generate_create_query_for_sentences(sentences)
    query_string = "CREATE " + sentences.each_with_index.to_a.map do |data, index|
      sentence_query_components(*data, index)
    end.join(", ")
  end

  def execute(query_string)
    Neo4j::Session.query(query_string)
  end

  def clear
    Node.delete_all
  end

  def verbs
    non_aux_verb_query = "MATCH (verb:Node) WHERE verb.part_of_speech =~ 'VB.?'
                          MATCH p=(verb)--(x)
                          WHERE NOT ANY (r in relationships(p) WHERE r.label =~ 'aux.*')
                          RETURN DISTINCT verb;"
    Neo4j::Session.query(non_aux_verb_query).map { |e| e.verb }
  end

  def permitted_descendants(node, copula)
    standard_query = %q{match (verb:Node {uuid: "NODE_UUID"})
                        match p=(verb)-[*]->(related)
                        where NOT ANY (l IN ['advcl'] WHERE ANY (r IN relationships(p) WHERE r.label =~ l))
                        return verb, related;}
    copula_query = %q{match (verb:Node {uuid: "NODE_UUID"})
                      match (cop:Node)-[rel_cop:REL]->(verb)
                      match p=(cop)-[*]->(related)
                      where rel_cop.label = "cop"
                      and NOT ANY (l IN ['advcl'] WHERE ANY (r IN relationships(p) WHERE r.label =~ l))
                      and related <> verb
                      return verb, cop, related;}
    if copula
      results = []
      [standard_query, copula_query].each do |query|
        query.gsub!('NODE_UUID', node.uuid)
        results << Neo4j::Session.query(query).to_a
      end
      return results.max_by(&:size)
    end
    Neo4j::Session.query(standard_query.gsub('NODE_UUID', node.uuid))
  end

  def permitted_descendant_string(node, copula=false)
    permitted_descendants(node, copula).to_a.map do |result|
      result.to_h.to_a.map(&:last)
    end.flatten.uniq.sort_by(&:index).map(&:word).join(" ")
  end
end
