module Counters
  def self.counter_points(points)
    antonyms = JSON.parse(File.open("antonyms.json").read)
    groups = points.group_by { |p| p["Components"] }

    counters = counters_for_points(points, groups, antonyms)

    counters.each do |k, v|
      v.each do |counter|
        counters.delete(counter) # remove mirrors
      end
    end

    counters.sort_by { |k, v| groups[k].size + groups[v.first].size }.reverse
  end

  def self.replacement_options(point, antonyms)
    [].tap do |options|
      point["Components"].map { |c| c.split(".").first }.each do |w|
        options << (antonyms[w] || [w])
      end
    end
  end

  def self.counters_for_points(points, groups, antonyms)
    {}.tap do |counter_points|
      points.uniq { |p| p["Components"] }.each do |p|
        options = replacement_options(p, antonyms)

        next if options.flatten == p["Components"].map { |c| c.split(".").first }

        permutations = options.first.map { |index| [index] }
        options[1..-1].each do |o|
          permutations.each do |permutation|
            new_permutations = []
            o.each do |w|
              new_permutations << (permutation + [w])
            end
            permutations = new_permutations
          end
        end

        counter_points[p["Components"]] = permutations.map do |permutation|
          permutation.zip(p["Relations"]).map { |x| x.join(".") }
        end.select { |p| groups[p] }
      end
    end.reject! { |_, v| v.empty? }
  end
end
