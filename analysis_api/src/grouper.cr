require "json"

module Grouper
  def self.run
    topics = ["access", "apple", "bad", "case", "court", "data", "encryption", "fbi", "good", "government", "icloud", "nsa", "password", "people", "phone", "point", "precedent", "public", "secure", "security", "time"]
    topics2 = ["arrington", "day", "hard", "hours", "jwz", "life", "lot", "make", "money", "people", "point", "smart", "startup", "time", "vc", "work", "worked", "working", "years"]

    points = File.read_lines("points2")
    points = points.map {|p| JSON.parse(p).as_a.map(&.to_s) }

    matched = [] of Array(String)
    points.each_with_index do |p, i|
      next if matched.includes? p
      same = [] of Array(String)
      points.each_with_index do |p2, i2|
        next if i == i2
        next if matched.includes? p2
        if (p2 - p).size == 0 || (p - p2).size == 0
          same << p2
          matched << p
          matched << p2
        end
      end
      if same.size > 0
        print i
        puts p
        same.each do |p|
          puts "  " + p.to_s
        end
      end
    end
  end
end

Grouper.run
