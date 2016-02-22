module Grouper
  def self.run
    points = File.read_lines("points").map { |l| l.chomp.split(" ") }
    groups = [] of Array(Array(String))

    topics = ["access", "apple", "bad", "case", "court", "data", "encryption", "fbi", "good", "government", "icloud", "nsa", "password", "people", "phone", "point", "precedent", "public", "secure", "security", "time"]

    points = points.map { |p| p.join(" ") }.map(&.downcase)

    groups = topics.map do |t|
      [t, points.select { |p| p.includes? t }]
    end.sort_by(&.last.size).reverse

    groups.each do |g|
      puts g.first
      puts g.last
      puts
    end

  end

end

Grouper.run
