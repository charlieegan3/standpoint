class Summary
  attr_accessor :topics, :counter_points, :related_points, :negated_points,
    :common_points, :longer_points, :commonly_discussed_topic_points,
    :multiple_topic_points, :question_points

  def initialize(title, points, topics, point_count)
    @title, @points, @topics, @point_count = title, points, topics, point_count
    @groups = Hash[*points.group_by { |p| p["Components"] }.sort_by { |_, v| v.size }.reverse.flatten(1)]
    @used_points = []
  end

  def build
    @counter_points = generate_counter_points; print "."
    @related_points = generate_related_points; print "."
    @negated_points = generate_negated_points; print "."
    @common_points = generate_common_points; print "."
    @longer_points = generate_longer_points; print "."
    @commonly_discussed_topic_points = generate_commonly_discussed_topic_points; print "."
    @multiple_topic_points = generate_multiple_topic_points; print "."
    @question_points = generate_question_points; print ".\n"
  end

  def generate_counter_points
    count = 0
    Counters.counter_points(available_points).map do |point, counter|
      next if count >= @point_count
      point = Curator.select_best(@groups[point])
      counter = Curator.select_best(@groups[counter])
      next if [point, counter].map(&:nil?).any?
      count += 1
      use_point(point); use_point(counter)
      [point, counter]
    end.compact
  end

  def generate_related_points
    count = 0
    used_related_points = []
    Related.related_points(available_points).map do |point, related|
      next if count >= @point_count
      point = Curator.select_best(@groups[point])
      related = Curator.select_best(@groups[related])
      next if [point, related].map(&:nil?).any?
      next unless (used_related_points & [point, related]).empty?
      count += 1
      used_related_points << point << related
      use_point(point); use_point(related)
      [point, related]
    end.compact
  end

  def generate_negated_points
    count = 0
    points = @groups.take(100).map do |_, group|
      next if count >= @point_count * 2
      counter_point_groups = Counters.negated_points(available_points(group))
      next if counter_point_groups.empty?
      best = counter_point_groups.map { |g| g.min_by { |r, _, _| r.length } }.min_by { |r, _, _| r.scan(/\||\{|\}/).size }
      next unless best
      count += 1
      use_point(best[1]); use_point(best[2])
      best[0] = Curator.clean_string(Condense.format_match_string(Condense.merge_diff_groups(best.first)))
      best
    end.compact.sort_by! { |best, _, _| best.scan(/\{|\}|\|/).size }
    if points.size > @point_count
      points.reverse.take(points.size - @point_count).each do |_, p1, p2|
        return_point(p1)
        return_point(p2)
      end
    end
    points.take(@point_count)
  end

  def generate_common_points
    count = 0
    @groups.map do |k, g|
      next if count >= @point_count
      best = Curator.select_best(available_points(g))
      next if best.nil?
      count += 1
      use_point(best)
    end.compact
  end

  def generate_longer_points
    count = 0
    used_topics = []
    [].tap do |points|
      @groups.reject { |k, v| k.size < 4 || v.size < 3 }.sort_by { |_, v| v.size }.reverse.map do |k, g|
        next if count >= @point_count
        best = Curator.select_best(available_points(g))
        next unless best
        topics = @topics.select { |t| best["String"].downcase.include?(t) || best["Lemmas"].select { |l| l.match(/[a-z]/) }.map { |l| l.split(":").first }.include?(t) }
        next if topics.empty? || (used_topics & topics).size > 1
        next if points.map { |p| p["String"] }.include? best["String"]
        count += 1
        used_topics += topics
        points << best
      end
    end
  end

  def generate_commonly_discussed_topic_points
    count = 0
    top_topics.map do |t|
      next if count >= @point_count
      topic_points = []
      @groups.select { |k, _| k.join(" ").include? " #{t}." }.each do |k, group|
        size = Condense.condense_group(topic_points.compact.map { |p| Presenter.clean(p["String"]) }).size
        next if size >= @point_count
        topic_points << Curator.select_best(group)
      end
      count += 1
      [t, topic_points.compact]
    end.compact
  end

  def generate_multiple_topic_points
    topic_points = @points.sort_by { |p| @topics.count { |t| p["String"].downcase.include? t } }.reverse.take(100)
    topic_points.uniq! { |p| p["String"] }
    selected_points = []
    for i in 0..10
      selected_points << topic_points.delete(Curator.select_best(topic_points))
      break if selected_points.size >= @point_count
    end
    selected_points
  end

  def generate_question_points
    count = 0
    question_groups = @points.select { |p| p["String"].include? "?" }
          .uniq {|p| p["String"] }
          .group_by { |p| p["Components"] }
          .sort_by { |k, v| v.size }
          .select { |k, v| v.size > 2 }
    question_groups.map do |_, group|
      next if count >= @point_count
      count += 1
      Curator.select_best_question(group)
    end.compact
  end

  def metadata
    {
      points: @points.size,
      groups: @groups.size,
      posts: @points.group_by { |p| p["Post"] }.size,
    }
  end

  def to_h
    {
      counter_points: @counter_points,
      related_points: @related_points,
      negated_points: @negated_points,
      common_points: @common_points,
      longer_points: @longer_points,
      commonly_discussed_topic_points: @commonly_discussed_topic_points,
      multiple_topic_points: @multiple_topic_points,
      question_points: @question_points,
    }
  end

  private

  def available_points(points=@points)
    points.select { |p| (@used_points & point_id_strings(p)).empty? }
  end

  def use_point(point)
    @used_points += point_id_strings(point)
    point
  end

  def return_point(point)
    @used_points -= point_id_strings(point)
    point
  end

  def point_id_strings(point)
    if point["Lemmas"]
      lemma_string = point["Lemmas"].select { |l| l.match(/[a-z]/) }.map { |l| l.split(":").first }.join(" ").downcase
    end
    [
      point["String"].gsub(/[^\w\s]+/, "").gsub(/\s+/, " ").strip.downcase,
      point["Components"].join(" "),
      Presenter.format(point["String"], @topics),
      lemma_string
    ].compact
  end

  def top_topics
    Utils.sorted_dup_hash(@groups.keys.flatten.map(&:downcase))
      .keys.select { |e|
        e.match(/nsubj|dobj/) &&
        !e.match(/person|they|\.verb|\.prep|it\.|what\.|that\.|one\./)
      }.map { |e| e.split(".").first }.uniq
  end
end
