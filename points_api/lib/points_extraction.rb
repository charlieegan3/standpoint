# points_extraction.rb
#
# This is the central file to extracting points from text. This is called from
# the application twice, first to get the verbs that have valid frame matches
# from in the database and then, for each of these, to get the extract
# information for the match as a complete point, ready to send in the response.

module PointsExtraction
  COPULAE = %w(act appear be become come end get go grow fall feel keep look prove remain run seem smell sound stay taste turn wax)

  # This will complete the points extraction process, given that some verbs
  # matched frames, this will complete the point structure to return
  def self.points_for_matches(neo4j_client, matches, topics, keys)
    points = matches.map do |verb, results|
      results.reject! { |r| r.first.to_a.compact.size < 2 }
      next if results.empty?
      string = neo4j_client.permitted_descendant_string(verb, PointsExtraction::COPULAE.include?(verb.lemma))
      results.map do |r|
        match = Hash[r.first.to_h.to_a.reject { |e| e.last.nil? }]
        if r.last.map { |f| f[:frames] }.uniq == [:generic] &&
             r.first.to_a.compact.size < 3 &&
             (match.map {|_, v| v.word } & topics).empty? &&
             (match.map {|_, v| v.word }.map(&:length).reduce(&:+) / match.size) < 5
          next
        end
        result = {}
        result.merge!(string: string) if keys.include? 'string'
        result.merge!(match: match) if keys.include? 'match'
        result.merge!(pattern: match.map { |k, v| "#{v.lemma}.#{k}" }.join(" ")) if keys.include? 'pattern'
        result.merge!(frames: r.last.map { |f| f[:frames] }.uniq) if keys.include? 'frames'
        result
      end
    end.flatten.compact
  end

  # this iterates all the verbs and tests that they each match frames, those
  # that do are returned
  def self.matches_for_verbs(neo4j_client, frames, frame_queries)
    verb_queries = neo4j_client.verbs.map do |v|
      queries_for_verb(v, frames, frame_queries).map do |q|
        { uuid: v.uuid, query: q.first, frames: q.last }
      end
    end.flatten.group_by { |e| e[:query] }

    verb_queries.map do |shared_query, frame_queries|
      shared_query = shared_query.gsub("UUIDS", frame_queries.map { |q| q[:uuid] }.join('", "'))
      neo4j_client.execute(shared_query).to_a.map { |r| [r, frame_queries] }
    end.flatten(1).compact.group_by { |r| r.first.verb }.reject { |_, v| v.empty? }
  end

  private
  # this fetches the cql queries for the frames
  def self.queries_for_verb(verb, frames, frame_queries)
    return [] unless frames[verb.lemma]
    frames = frames[verb.lemma].map { |f| Frame.new(f, verb.lemma) }
    if COPULAE.include? verb.lemma
      frames += Frame.copula_frames(verb.lemma)
    end
    [].tap do |queries|
      frames.group_by { |f| [f.pos_pattern_string, f.is_copula?] }.each do |pattern, frames|
        query_name = pattern.last ? pattern.first + '-cop' : pattern.first
        queries << [frame_queries[query_name], frames] if frame_queries[query_name]
      end
    end.push([frame_queries['VERB-UNIVERSAL'], :generic])
  end
end