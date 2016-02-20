class PointExtractor
  def initialize(neo4j_client, verbs, frame_queries)
    @neo4j_client, @verbs, @frame_queries = neo4j_client, verbs, frame_queries
    @copulae = %w(act appear be become come end get go grow fall feel keep look prove remain run seem smell sound stay taste turn wax)
  end

  def point(verb)
    [].tap do |points|
      points << generic_point(verb)
      break unless @verbs[verb.lemma]
      points.push(*frame_points(verb))
    end.sort_by(&:size).last
  end

  private

  def generic_point(verb)
    @neo4j_client.query(verb, @frame_queries['VERB-UNIVERSAL'])
      .map { |e| { match: e, component: :generic} }
      .sort_by { |e| e[:match][:node].index }
  end

  def frame_points(verb)
    frames = @verbs[verb.lemma].map { |f| Frame.new(f, verb.lemma) }
    if @copulae.include? verb.lemma
      frames += Frame.copula_frames(verb.lemma)
    end
    [].tap do |points|
      frames.group_by { |f| [f.pos_pattern_string, f.is_copula?] }.each do |pattern, frames|
        query_name = pattern.last ? pattern.first + '-cop' : pattern.first
        query = @frame_queries[query_name]
        next unless query
        match = @neo4j_client.query(verb, query)
        unless match.empty?
          frames.each do |frame|
            points << match.zip(frame.components)
              .map { |m, c| { match: m, component: c } }
              .sort_by { |e| e[:match][:node].index }
          end
        end
      end
    end
  end
end
