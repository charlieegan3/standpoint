class Tree::TreeNode
  def remove_range!(range)
    self.children[range].each do |child|
      self.remove!(child)
    end
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

  def search(component)
    if match(component) && !children_match(component)
      return self
    elsif !self.children.empty?
      self.children.each do |c|
        if (child_node = c.search(component)).class == Tree::TreeNode
          return child_node
        end
      end
      return false
    else
      return false
    end
  end

  def match(component)
    if component[:regex]
      !(component[:regex] =~ self.content).nil?
    else
      self.content == component[:string]
    end
  end

  def scan(pattern)
    [].tap do |matches|
      pattern.components.each do |component|
        if result = self.search(component)
          matches << { matcher: component, tree: result }
          next unless result.parent
          result.parent.remove_range!(0..result.index_at_parent)
        else
          puts "Failed: \"#{component}\" missing"
          return false
        end
      end
    end
  end
end
