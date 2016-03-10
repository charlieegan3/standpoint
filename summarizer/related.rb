module Related
  def self.related_points(points)
    posts = points.group_by { |p| p["Post"] }

    ptoi = {}
    itop = {}
    points.each_with_index { |p, i| ptoi[p["Components"]] = i; itop[i] = p }

    posts = posts.map { |k, v| v.map { |p| ptoi[p["Components"]] }.uniq }

    related = Hash.new(0)
    posts.each do |p|
      p.combination(2).to_a.each do |c|
        related[c] += 1
      end
    end

    related = related.reject { |k,v| v < 3 }
    related = related.sort_by { |k, v| v }.reverse

    related.map do |points, count|
      points.map! { |p| itop[p] }
      if (points.first["Components"] & points.last["Components"]).size > 1
        next
      end
      [points.map { |p| p["Components"] }, count]
    end.compact
  end
end
