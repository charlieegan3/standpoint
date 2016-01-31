class Parser
  def self.prepare_sentence(sentence)
    sentence.gsub(/\(|\)/, ',')
  end

  def self.parse_tree(tree)
    tree_syntax = tree.gsub("\n", " ")
      .gsub(/\s+/, ' ')
      .gsub('(', '("')
      .gsub(/([^\)])\)/, '\1")')
      .gsub(/ ([^\(])/, ' "\1')
      .gsub(/([^\)]) /, '\1" ')
      .gsub(' ', ', ')
      .gsub('(', '[')
      .gsub(')', ']')
      .gsub(/\["\W",/, '["PUNC", ')
    eval(tree_syntax)[1]
  end

  def self.build_tree(parsed_tree)
    root_node = Tree::TreeNode.new("ROOT", "root")
    root_node << create_child(parsed_tree)
  end

  private

  def self.create_child(node)
    child = Tree::TreeNode.new(node.first, node.first)
    node[1..-1].each do |c|
      if c.class == Array
        grand_child = create_child(c)
        if (count = child.child_names.count(grand_child.name)) > 0
          grand_child.rename(grand_child.name + count.to_s)
        end
        child << grand_child
      else
        child << Tree::TreeNode.new(c, c)
      end
    end
    return child
  end
end
