# counters.rb
#
# This file implements the search process for both counter and negated points.

module Counters
  PATTERN = /(\W|^)(n't|no|not|none|no one|nobody|nothing|neither|nowhere|never)(\W|$)/i
  def self.counter_points(points)
    antonyms = JSON.parse(File.open("antonyms.json").read)
    groups = points.group_by { |p| p["Components"] }

    counters = counters_for_points(points, groups, antonyms)

    counters.each do |k, v|
      v.each do |counter|
        counters.delete(counter) # remove mirrors
      end
    end

    counters.reject! { |k, _| k.size == 2 && k.join(" ").match(/(go|come)\.verb(\s|$)/) }

    counters.map {|k, v| v.map { |c| [k, c] }}
      .flatten(1)
      .sort_by { |k, v| groups[k].size + groups[v].size }
      .reverse
  end

  def self.negated_points(points)
    plain, neg = points.group_by { |p| p["String"].downcase.match(PATTERN).nil? }
      .map(&:last)
      .map { |g| Curator.reparse_points(Curator.select_best(g, true)) }

    return [] unless plain && neg
    neg.select! {|p| p["Relations"].include? "neg" }
    return [] if neg.empty?

    plain, neg = [plain, neg].map { |g| g.uniq { |p| Curator.clean_string(p["String"]) }  }

    counter_points = []
    plain.product(neg).each do |p1, p2|
      s1 = p1["String"].downcase.gsub(/[^\s\w']/, "").strip
      s2 = p2["String"].downcase.gsub(/[^\s\w']/, "").strip
      next if Levenshtein.distance(s1, s2) > 20
      res = Differ.diff_by_word(s1, s2).to_s.gsub('"', "").gsub(" >> ", "|")
      res = res.gsub("{+s}", "").gsub(/\|s\}/, "}").gsub(/\-|\+/, "")
      next unless res.include?("{")
      next if res.match(/\}\w\{/) || res.match(/\w(\{|\})\w/) || res.match(/\w(\{|\})\w/)
      next if res.chars.count("|") > 1
      next if (s1.split(" ").size - s2.split(" ").size).abs > 6
      next if (s1.split(" ") & s2.split(" ")).size < (s1.split(" ") + s2.split(" ")).size.to_f / 4
      next if res.scan(/\{[^\}]+\}/).size > 2
      next if res.scan(/\{[^\}]+\}/).join(" ").gsub(/[^\w\s]+/, " ").scan(/\w+ /).size > res.gsub(/[^\w\s]/, " ").scan(/\w+ /).size * 0.75
      next if res.scan(/\{[^\}]+\}/).map { |s| s.scan(/\w+ /).size }.max > 5
      counter_points << [res, p1, p2]
    end

    counter_point_groups = []
    counter_points.sort_by { |cp| cp.first.length  }.reverse.each do |cp|
      allocated = false
      counter_point_groups.each_with_index do |g, i|
        g.each do |s|
          next if Levenshtein.distance(cp.first, s.first) > 20
          allocated = true
          counter_point_groups[i] << cp
          break
        end
        break if allocated
      end
      counter_point_groups << [cp] unless allocated
    end
    return counter_point_groups
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

        permutations = []
        options.each_with_index do |set, index|
          set.each do |replacement|
            new = p["Components"].dup
            new[index] = "#{replacement}.#{p["Components"][index].split(".").last}"
            next if new == p["Components"]
            permutations << new
          end
        end

        counter_points[p["Components"]] = permutations.select { |p| groups[p] }
      end
    end.reject! { |_, v| v.empty? }
  end
end
