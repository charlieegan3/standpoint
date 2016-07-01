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

  def point_pattern_graph
    nodes, edges = [], []
    point_clusters.each do |k, v|
      v.each do |point|
        tokens = point.pattern.split(" ")
        nodes += tokens
        (0...tokens.size - 1).to_a.each { |i| edges << tokens[i, 2] }
      end
    end
    return { nodes: nodes, edges: edges }
  end
end
