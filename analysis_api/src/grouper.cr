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

  def to_s
    "(" + components.join(" ") + ") : " + string
  end
end

module Grouper
  def self.run
    input = File.read_lines("points5")
    topics = JSON.parse(input.first).as_a.map(&.to_s)
    puts "TOPICS: " + topics.join(" ")
    puts "="*120
    points = input[1..-1]
    points = points.map {|p| JSON.parse(p).as_h }
    points = points.map do |p|
      Point.new(
        (p["string"] as String),
        (p["point"] as Array)
      )
    end

    puts
    puts "GROUPED (auto)"
    puts "="*120

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
      verb_groups[v] = points.select(&.includes?(v+".verb")).map(&.to_s)
    end

    puts "GROUPED (by verb, then topic)"
    puts "="*120

    verb_groups.to_a.sort_by { |v| v[1].size }.map { |v| [v[0], v[1].uniq] as Array }.each do |v|
      next if v.last.empty?
      puts (v.first as String).upcase
      topic_groups = {} of String => Array(String)
      matched = [] of String
      topics.each do |t|
        topic_groups[t] = (v.last as Array).select { |s| (s.includes? t) && (!matched.includes? s) }
        matched += topic_groups[t]
      end
      remaining = (v.last as Array) - topic_groups.to_a.map { |v| v[1] }.flatten
      unless remaining.empty?
        puts "   ** Unsorted **"
        remaining.map {|s|puts "       "+s}
      end
      topic_groups.each do |t, v|
        next if v.empty?
        puts "   " + t
        v.each do |s|
          puts "       " + s[0..130]
        end
      end
    end

    #puts "MANUAL"

    #points.uniq(&.string).each do |p|
      #puts p.string
    #end
    #buckets = {} of String => Array(String)
    #points.uniq(&.string).each do |p|
      #puts p.string
      #print "> "
      #res = (gets as String).chomp
      #break if res == "exit"
      #buckets[res] = [] of String unless buckets.has_key? res
      #buckets[res] << p.string
    #end
    #puts "MANUAL Grouping"
    #buckets.each do |k, v|
      #puts k
      #v.each do |s|
        #puts "   " + s[0..130]
      #end
    #end
  end
end

Grouper.run
