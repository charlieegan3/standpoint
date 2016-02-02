class Tree::TreeNode
  def remove_range!(range)
    self.children[range].each do |child|
      self.remove!(child)
    end
  end

  def leaf_nodes
    [].tap do |leaves|
      each_leaf do |leaf|
        leaves << leaf if leaf.is_leaf?
      end
    end.compact
  end

  def str
    leaf_nodes.map(&:name)
  end

  def node_list
    each { |n| n }.map { |n| n }
  end

  def contains?(leaf)
    leaf_nodes.map(&:name).include? leaf
  end

  def index_at_parent
    return 0 unless self.parent
    self.parent.children.index(self)
  end

  def child_names
    self.children.map(&:content)
  end

  def children_match(component)
    self.children.map { |c| c.match(component) }.reduce(:|)
  end

  def scan(pattern)
    tree_index = node_list

    component_matches = []
    pattern.components.each do |component|
      nodes = Hash.new
      tree_index.each_with_index do |node, index|
        range = node.leaf_nodes.map { |n| tree_index.index(n) }.sort
        nodes[range] = node if node.match(component)
      end
      component_matches << nodes
    end

    indexes = component_matches.map(&:keys)

    valid_match_list = []

    indexes.map! do |component_matches|
      component_matches.map do |match|
        match.sort
      end
    end

    indexes.reduce(:+).combination(indexes.size).to_a.each do |c|
      next unless c == c.sort_by { |x| x.last }
      next unless c == c.sort_by { |x| x.first }
      valid = true
      indexes.each_with_index do |component_match, index|
        valid = false unless component_match.include? c[index]
      end
      valid_match_list << c if valid
    end

    valid_match_list.reject! { |m| m.flatten.uniq != m.flatten }
    valid_match_list.uniq!

    leaf_map = each { |n| n }.map { |n| n }.map {|n| n.is_leaf? }

    scores = valid_match_list.map do |m|
      distances = []
      m.each_with_index do |c, i|
        break unless m[i+1]
        range = c.last+1...m[i+1].first
        distances << leaf_map[range].count(true)
      end
      1 - (distances.reduce(:+).to_f / m.size)
    end

    full_matches = []
    valid_match_list.each do |match|
      full_match = []
      match.each_with_index do |key, index|
        full_match << component_matches[index][key]
      end
      full_matches << full_match
    end

    full_matches.each_with_index do |match, index|
      sub_matches = []
      match.each_with_index do |sub_match, index|
        sub_matches << {
          pattern: pattern.components[index], tree: sub_match }
      end
      full_matches[index] = { score: scores[index], sub_matches: sub_matches}
    end

    return full_matches
  end

  def match(component)
    if component[:regex]
      !(component[:regex] =~ self.content).nil?
    else
      self.content == component[:string]
    end
  end
end
