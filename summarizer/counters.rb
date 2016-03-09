require 'json'
require 'pry'

antonyms = JSON.parse(File.open("antonyms.json").read)
points = File.open(ARGV[0]).readlines[1..-1].map { |x| JSON.parse(x) }
groups = points.group_by { |p| p["Components"].join(" ") }

counter_points = {}
points.uniq { |p| p["Components"] }.each do |p|
  options = []
  p["Components"].map { |c| c.split(".").first }.each do |w|
    options << (antonyms[w] || [w])
  end

  next if options.flatten == p["Components"].map { |c| c.split(".").first }

  permutations = options.first.map { |x| [x] }
  options[1..-1].each do |o|
    permutations.each do |permutation|
      new_permutations = []
      o.each do |w|
        new_permutations << (permutation + [w])
      end
      permutations = new_permutations
    end
  end

  permutations.map do |permutation|
    if permutation.zip(p["Relations"]).map { |x| x.join(".") }.join(" ") == p["Components"].join(" ")
      binding.pry
    end
  end

  counter_points[p["Components"].join(" ")] = permutations.map do |permutation|
    permutation.zip(p["Relations"]).map { |x| x.join(".") }.join(" ")
  end.select { |p| groups[p] }
end

counter_points.reject! { |_, v| v.empty? }
counter_points.each do |k, v|
  v.each do |counter|
    counter_points.delete(counter)
  end
end

counter_points.each do |point, counters|
  counters.each do |c|
    point_extracts = groups[point].map { |p| "      " + p["String"] }.uniq.take(20)
    counter_extracts = groups[c].map { |p| "      " + p["String"] }.uniq.take(20)
    next if counter_extracts.size < 3 || point_extracts.size < 3
    puts "========== COUNTER POINT =========="
    puts "  Point: #{point}"
    puts "Counter: #{c}"
    puts "Point Extracts: (max 20 listed)"
    puts point_extracts
    puts "Counter Extracts: (max 20 listed)"
    puts counter_extracts
    puts
  end
end
