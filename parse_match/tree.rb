require 'tree'
require 'pp'
require 'json'
require 'net/http'

class Parser
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
        child << Tree::TreeNode.new(name, c)
      end
    end
    return child
  end
end

class Tree::TreeNode
  def remove_range!(range)
    self.children[range].each do |child|
      self.remove!(child)
    end
  end

  def index_at_parent
    self.parent.children.index(self)
  end

  def child_names
    self.children.map(&:content)
  end

  def search(component)
    if match(component)
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
      component[:regex] =~ self.content
    else
      self.content == component[:string]
    end
  end

  def scan(pattern)
    [].tap do |matches|
      pattern.components.each do |component|
        if result = self.search(component)
          matches << { matcher: component, tree: result }
          result.parent.remove_range!(0..result.index_at_parent)
        else
          puts "Failed: \"#{component[:original]}\" missing"
          return false
        end
      end
    end
  end
end

class Pattern
  attr_reader :components, :pattern_string

  def initialize(pattern_string)
    @pattern_string = pattern_string
    @components = translate(pattern_string)
  end

  private

  def translate(pattern_string)
    [].tap do |components|
      pattern_string.split.each do |component|
        if t = translation(component)
          components << t
        else
          components << component
        end
      end
    end
  end

  def translation(component)
    regex = {
      "V" => /VB[^A-Z]?/,
    }[component]
    {
      original: component,
      regex: regex,
      string: clean_component(component),
      tags: tags_for_component(component)
    }
  end

  def tags_for_component(component)
    component.scan(/\.(\w+)/).flatten
  end

  def clean_component(component)
    component.gsub(/\.\w+/, '').gsub(/\W+/, '')
  end
end


uri = URI('http://corenlp_server:9000/?properties=%7B%22tokenize.whitespace%22:%20%22true%22,%20%22annotators%22:%20%22parse%22,%20%22outputFormat%22:%20%22json%22%7D')

http = Net::HTTP.new(uri.host, uri.port)

concepts = JSON.parse(File.open('concepts.json', 'r').read)
concepts.each do |k,v|
  v['frames'].each do |f|
    pattern = f['pattern']
    sentence = f['examples'].first

    req =  Net::HTTP::Post.new(uri)
    req.add_field "Content-Type", "plain/text"
    req.body = sentence

    res = http.request(req)
    parse = JSON.parse(res.body)['sentences'].first['parse']

    tree = Parser.parse_tree(parse)
    tree = Parser.build_tree(tree)

    # puts sentence
    # puts pattern
    puts tree.scan(Pattern.new(pattern)) != false

    # tree.print_tree
    # gets
  end
end
