class Neo4jClient
  def initialize(url)
    Neo4j::Session.open(:server_db, url)
  end

  def create(tokens, dependencies)
    nodes = tokens.map do |t|
      [t['word'], t['pos'], t['lemma'], t['index'].to_i-1]
    end
    relations = dependencies.uniq.map do |d|
      [d['dep'], d['governor'].to_i-1, d['dependent'].to_i-1]
    end
    relations.reject! { |l, g, d| g == d || l == 'ROOT'}

    nodes.map! do |word, pos, lemma, index|
      Node.new(word: word, part_of_speech: pos,
               lemma: lemma, index: index)
    end

    relations.each do |label, parent_index, child_index|
      Relation.create(
        from_node: nodes[parent_index],
        to_node: nodes[child_index],
        label: label)
    end
  end

  def clear
    Node.delete_all
  end

  def verbs
    Node.where(part_of_speech: /VB.?/)
  end

  def query(verb, query)
    linked_query = query.gsub('VERB_UUID', verb.uuid)
    Neo4j::Session.query(linked_query)
  end
end
