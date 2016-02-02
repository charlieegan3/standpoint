require "test/unit"
require "pry"

class Test::Unit::TestCase
  def disrespect_privacy(object_or_class, &block)
    raise ArgumentError, 'Block must be specified' unless block_given?
    yield Disrespect.new(object_or_class)
  end

  class Disrespect
    def initialize(object_or_class)
      @object = object_or_class
    end
    def method_missing(method, *args)
      @object.send(method, *args)
    end
  end
end
