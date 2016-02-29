require "json"

class Point
  getter :string, :components, :words, :verb, :relations
  def initialize(string : String, components : Array)
    @components, @string = components, string
    @components.map!(&.gsub(/cop|pass/, ""))
    @words = @components.map(&.split(".").first)
    @relations = @components.map(&.split(".").last)
    @verb = @components.select { |c| c.includes? ".verb" }.first.split(".").first
  end

  def matches?(point : Point)
    return false if point == self
    return false unless verb == point.verb
    matches_words(point) || matches_components(point)
  end

  def matches_components(point : Point)
    (components - point.components).empty? &&
    (point.components - components).empty?
  end

  def matches_words(point : Point)
    words == point.words
  end

  def verb
    components.select { |c| (c as String).includes? "verb" }.first.to_s
  end

  def includes?(lemma)
    components.join(" ").includes?(lemma)
  end

  def to_s
    "(" + components.join(" ") + ") : " + string
  end
end

module Grouper
  def self.run
    input = File.read_lines("points6")
    topics = JSON.parse(input.first).as_a.map(&.to_s)
    puts "TOPICS: " + topics.join(" ")
    puts "="*120
    points = input[1..-1]
    points = points.map {|p| JSON.parse(p.split(" ")[1..-1].join(" ").gsub(" =>", ":")) }

    points = points.map do |p|
      Point.new(p["string"].to_s, p["pattern"].to_s.split(" "))
    end

    blacklist = %w(it.nsubj that.nsubj this.nsubj which.nsubj what.nsubj)
    points.reject! { |p| blacklist.includes? p.components.first }

    personlist = %w(I.nsubj you.nsubj they.nsubj he.nsubj she.nsubj)
    points.map! do |p|
      if personlist.includes? p.components.first
        p.components[0] = "PERSON.nsubj"
      end
      p
    end

    puts
    puts "GROUPED (auto)"
    puts "="*120

    matched = [] of Point
    groups = [] of Array(Point)
    size = points.size
    points.each_with_index do |point, index|
      puts (index.to_f / size) * 100 if index % 300 == 0
      next if matched.includes? point
      matched << point
      group = [] of Point
      points.each do |inner_point|
        if point.matches?(inner_point)
          group << inner_point
          matched << inner_point
        end
      end

      next if group.size < 3
      groups << group
    end

    groups.sort_by(&.size).reverse.each do |g|
      puts g.first.components.join(" ")
      g.uniq(&.string).each do |p|
        puts "   " + p.string
      end
    end
  end
end

Grouper.run
