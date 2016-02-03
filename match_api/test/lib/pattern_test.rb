require "test/unit"

require_relative "../../lib/pattern"

Pattern.send(:public, :tags_for_component)
Pattern.send(:public, :clean_component)
Pattern.send(:public, :multi_component_substitute)

class TestPattern < Test::Unit::TestCase
  def test_init
    pattern = Pattern.new("NN V NN")
    assert_equal("NN V NN", pattern.pattern_string)
    assert_equal(
      {original: "NN", string: "NN", regex: nil, tags: []},
      pattern.components.first
    )
    assert_equal(
      pattern.pattern_string.split(" ").size,
      pattern.components.size
    )
  end

  def test_tags_for_component
    @pattern = Pattern.new("")
    disrespect_privacy @pattern do |p|
      assert_equal([], @pattern.tags_for_component("NN"))
      assert_equal(%w(tag), @pattern.tags_for_component("NN.tag"))
      assert_equal(%w(tag tag2), @pattern.tags_for_component("NN.tag.tag2"))
      assert_equal(%w(tag tag2), @pattern.tags_for_component("NN-tag.tag2"))
    end
  end

  def test_clean_component
    @pattern = Pattern.new("sdf")
    disrespect_privacy @pattern do |p|
      assert_equal("NN", @pattern.clean_component("NN"))
      assert_equal("NN", @pattern.clean_component("NN-"))
      assert_equal("NN", @pattern.clean_component("-NN-"))
      assert_equal("NN", @pattern.clean_component("-NN.tag-thing"))
      assert_equal("NN", @pattern.clean_component("-NN.tag.thingthing"))
    end
  end

  def test_multi_component_substitute
    @pattern = Pattern.new("")
    disrespect_privacy @pattern do |p|
      assert_equal("VP", @pattern.multi_component_substitute("V NP"))
    end
  end
end
