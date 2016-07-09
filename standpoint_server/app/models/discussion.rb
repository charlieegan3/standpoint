class Discussion < ActiveRecord::Base
  has_many :comments, dependent: :destroy

  def root_comments
    comments.where(parent: nil).order('votes DESC')
  end

  def point_clusters
    comments.map(&:points)
      .flatten
      .group_by(&:pattern)
      .sort_by { |k, v| v.size }
      .reverse
  end

  def chord_data
    connections = Hash.new([])
    point_clusters.map(&:first).take(30).each do |pattern|
      tokens = pattern.split(" ")
      (0...tokens.size - 1).to_a.each do |i|
        connections[tokens[i]] += [tokens[i + 1]]
      end
    end
    connections.map do |k, v|
      lemma, pos = k.split(".")
      { name: k, lemma: lemma, type: pos, connections: v.uniq }
    end
  end

  def graph_data
    nodes, edges = [], []
    point_clusters.each do |k, v|
      v.each do |point|
        tokens = point.pattern.split(" ")
        nodes += tokens
        (0...tokens.size - 1).to_a.each { |i| edges << tokens[i, 2] }
      end
    end
    name_index = Hash.new()
    nodes = Utils.sorted_dup_hash(nodes).take(30).each_with_index.to_a.map do |e, i|
      lemma, pos = e[0].split(".")
      name_index[e[0]] = i
      { name: e[0], lemma: lemma, group: pos, value: e[1] }
    end
    edges = Utils.sorted_dup_hash(edges).map do |k, v|
	  source, target = name_index[k.first], name_index[k.last]
      next if source.nil? || target.nil?
      { source: name_index[k.first], target: name_index[k.last], value: v }
    end.compact
    return { nodes: nodes, links: edges }
  end

  def matching_patterns(pattern)
    return [] if pattern.blank?
    point_clusters.select { |k, _| k.downcase.include? pattern.downcase }
  end

  def matching_extracts(word)
    return [] if word.blank?
    point_clusters.map do |k, v|
      [k, v.select { |point| point.extract.downcase.include? word.downcase }]
    end.reject { |_, v| v.empty? }
  end

  def top_nouns
    nouns = comments.map(&:points)
      .flatten
      .collect(&:pattern)
      .map { |p| p.split(" ") }
      .flatten
      .select { |p| p.include? "noun" }
      .reject { |p| p.include? "PERSON" }
    return Utils.sorted_dup_hash(nouns).to_a
  end
end
