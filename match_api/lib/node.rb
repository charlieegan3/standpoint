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
    leaf_nodes.map(&:content)
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

  def match(component)
    if component[:regex]
      !(component[:regex] =~ self.content).nil?
    else
      self.content == component[:string]
    end
  end

  def scan(pattern, verb)
    component_matches = matches_for_pattern_components(pattern)
    valid_sequences = valid_component_sequences(component_matches)
    matches = sequences_to_matches(component_matches, valid_sequences)
    scores = scores_sequences(valid_sequences)

    matches = matches.each_with_index.to_a.map do |match, index|
      component_matches = []
      match.each_with_index do |sub_match, index|
        component_matches << {
          pattern: pattern.components[index], tree: sub_match }
      end
      {
        string: match_string(component_matches),
        frame: pattern.pattern_string,
        verb: verb,
        score: scores[index],
        component_matches: component_matches
      }
    end

    matches.select! { |m| m[:string].include? verb[:text] }

    return matches
  end

  private

  def match_string(component_matches)
    component_matches.map do |component_match|
      component_match[:tree].str
    end.flatten.join(" ")
  end

  # array of hashes, keys link indexes to trees
  def matches_for_pattern_components(pattern)
    tree_index = node_list
    [].tap do |component_matches|
      pattern.components.each do |component|
        nodes = Hash.new
        tree_index.each_with_index do |node, index|
          range = node.leaf_nodes.map do |n|
            tree_index.map(&:object_id).index(n.object_id)
          end.sort
          nodes[range] = node if node.match(component)
        end
        component_matches << nodes
      end
    end
  end

  # generates valid sequences of component indexes
  # additional complexity due to removal of invalid combinations
  # invalid if: not ordered, not correct type at pattern index
  def valid_component_sequences(component_matches)
    indexes = component_matches.map(&:keys)
    all_matches_for_indexes = indexes.reduce(:+).combination(indexes.size).to_a

    [].tap do |valid_sequences|
      all_matches_for_indexes.to_a.each do |c|
        next unless c == c.sort_by { |x| x.last }
        next unless c == c.sort_by { |x| x.first }
        valid = true
        indexes.each_with_index do |component_match, index|
          valid = false unless component_match.include? c[index]
        end
        valid_sequences << c if valid
      end
    end.reject { |m| m.flatten.uniq != m.flatten }.uniq
  end

  # take sequences and get the components for the index values
  def sequences_to_matches(components, sequences)
    sequences.map do |sequence|
      [].tap do |match|
        sequence.each_with_index do |key, index|
          match << components[index][key]
        end
      end
    end
  end

  def scores_sequences(sequence_list)
    leaf_map = each { |n| n }.map { |n| n }.map {|n| n.is_leaf? }
    sequence_list.map do |m|
      distances = []
      m.each_with_index do |c, i|
        break unless m[i+1]
        range = c.last+1...m[i+1].first
        distances << leaf_map[range].count(true)
      end
      1 - (distances.reduce(:+).to_f / m.size)
    end
  end

end
