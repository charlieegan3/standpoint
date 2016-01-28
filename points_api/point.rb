class Point
  attr_accessor :components, :parent

  def initialize(parent)
    @components = []
    @parent = parent
  end

  def add_component(key, index, text)
    @components << Component.new(key, index, text)
  end

  def string
    @parent.words.values[word_range].join(" ")
  end

  def word_range
    @components.first.index-1..@components.last.index-1
  end

  class Component
    attr_accessor :key, :index, :text
    def initialize(key, index, text)
      @key, @index, @text = key, index, text
    end
  end
end
