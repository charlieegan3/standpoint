class Discussion < ActiveRecord::Base
  has_many :comments

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
    nodes = Utils.sorted_dup_hash(nodes).take(25).each_with_index.to_a.map do |e, i|
      name, type = e[0].split(".")
      name_index[e[0]] = i
      { name: name, group: type, value: e[1] }
    end
    edges = Utils.sorted_dup_hash(edges).map do |k, v|
	  source, target = name_index[k.first], name_index[k.last]
      next if source.nil? || target.nil?
      { source: name_index[k.first], target: name_index[k.last], value: v }
    end.compact
    return { nodes: nodes, links: edges }
  end
end
