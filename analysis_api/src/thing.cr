module Thing
  def self.run
    points = File.read_lines("points").map { |l| l.chomp.split(" ") }
    groups = [] of Array(Array(String))


    points.each do |p|
      scores = [] of Float64
      groups.each do |g|
        scores << (g.flatten - p).size.to_f / g.flatten.size
      end

      unless scores.empty?
        if (min = scores.min) < 0.5
          index = scores.index(min)
          groups[index as Int] << p
        else
          groups << [p]
        end
      else
        groups << [p]
      end
    end

    groups.select { |x| x.size > 1 }.each do |g|
      puts g
    end

    puts groups.size
    puts points.size
  end

end

Thing.run
