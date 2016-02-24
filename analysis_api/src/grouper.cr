require "json"

class Point
  getter :string, :components
  def initialize(string : String, components : Array)
    @components, @string = components, string
  end

  def matches?(point : Point)
    return false if point == self
    (components - point.components).empty? &&
    (point.components - components).empty?
  end

  def verb
    components.select { |c| (c as String).includes? "verb" }.first.to_s
  end

  def includes?(lemma)
    components.join(" ").includes?(lemma)
  end
end

module Grouper
  def self.run
    points = File.read_lines("points2")[1..-1]
    points = points.map {|p| JSON.parse(p).as_h }
    points = points.map do |p|
      Point.new(
        (p["string"] as String),
        (p["point"] as Array)
      )
    end

    matched = [] of Point
    points.each_with_index do |point, index|
      next if matched.includes? point
      same = [] of Point
      points.each_with_index do |inner_point, index|
        if point.matches?(inner_point)
          same << inner_point
          matched << inner_point
        end
      end

      next if same.size < 2

      puts point.components.join(", ")
      puts "   " + point.string
      same.each do |p|
        puts "   " + p.string
      end
      puts
    end

    verb_groups = {} of String => Array(String)
    verbs = (points.map(&.verb) as Array(String)).map(&.gsub(".verb", "")).uniq
    verbs.each do |v|
      verb_groups[v] = points.select(&.includes?(v)).map(&.string)
    end

    verb_groups.to_a.sort_by { |v| v[1].size }.each do |v|
      puts v.first
      v.last.each do |p|
        print "     "
        p.size > 120 ? puts p[0..120]+"..." : puts p
      end
    end
  end
end

Grouper.run
