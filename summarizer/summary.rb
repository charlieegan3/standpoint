class Summary
  def initialize(title, points, topics)
    @title, @points, @topics = title, points, topics
    @groups = Hash[*points.group_by { |p| p["Components"] }.sort_by { |_, v| v.size }.reverse.flatten(1)]
  end

  def counter_points
    Counters.counter_points(@points).map do |point, counter|
      point = Curator.select_best(@groups[point])
      counter = Curator.select_best(@groups[counter])
      next if [point, counter].map(&:nil?).any?
      condensed = Condense.condense_group([point["String"], counter["String"]])
      condensed.size == 1 ? [true, point, counter] : [false, point, counter]
    end.compact
  end

  def related_points
    Related.related_points(@points).map do |point, related|
      point = Curator.select_best(@groups[point])
      related = Curator.select_best(@groups[related])
      next if [point, related].map(&:nil?).any?
      [point, related]
    end.compact
  end

  def negated_points
    @groups.map do |_, group|
      counter_point_groups = Counters.negated_points(group)
      next if counter_point_groups.empty?
      best = counter_point_groups.map { |g| g.min_by { |r, _, _| r.length } }.min_by { |r, _, _| r.scan(/\||\{|\}/).size }
      next unless best
      best[0] = Curator.clean_string(Condense.format_match_string(Condense.merge_diff_groups(best.first)))
      puts best
    end.compact
  end

  def common_points
    @groups.map do |k, g|
      Curator.select_best(g)
    end.compact
  end

  def longer_points
    # needs condensing
    @groups.reject { |k, v| k.size < 4 || v.size < 3 }.sort_by { |_, v| v.size }.reverse.map do |k, g|
      Curator.select_best(g)
    end.compact.uniq { |p| p["String"] }
  end

  def commonly_discussed_topic_points
    # needs condensing
    top_topics.take(10).map do |t|
      points = groups.select { |k, _| k.join(" ").include? " #{t}." }.take(5).map do |k, group|
        point = Curator.select_best(group)
      end.compact
      [t, points]
    end
  end

  def multiple_topic_points
    # needs condensing
    topic_points = @points.sort_by { |p| topics.count { |t| p["String"].downcase.include? t } }.reverse.take(100)
    topic_points.uniq! { |p| p["String"] }
    selected_points = []
    for i in 0..10
      selected_points << topic_points.delete(Curator.select_best(topic_points))
      break if selected_points.size > 5
    end
    selected_points
  end

  def question_points
    question_groups = points.select { |p| p["String"].include? "?" }
          .uniq {|p| p["String"] }
          .group_by { |p| p["Components"] }
          .sort_by { |k, v| v.size }
          .select { |k, v| v.size > 2 }
    question_groups.map do |_, group|
      Curator.select_best_question(group)
    end.compact
  end

  private

  def top_topics
    Utils.sorted_dup_hash(@groups.keys.flatten.map(&:downcase))
      .keys.select { |e|
        e.match(/nsubj|dobj/) &&
        !e.match(/person|they|\.verb|\.prep|it\.|what\.|that\.|one\./)
      }.map { |e| e.split(".").first }.uniq
  end
end
