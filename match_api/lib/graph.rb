require_relative 'node'
require_relative 'point'

class Graph
  attr_accessor :nodes, :edges

  def initialize(tokens, dependencies)
    nodes = tokens.map { |t| [t['word'], t['pos'], t['lemma'], t['index'].to_i-1] }
    edges = dependencies.uniq.map {|d| [d['dep'], d['governor'].to_i-1, d['dependent'].to_i-1] }
    edges.reject! { |l, g, d| g == d }

    blacklist = %w(ROOT)
    edges.reject! { |l,g,d| blacklist.include?(l) }

    @nodes = nodes.map { |w,p,l,i| Node.new(w, p, l, i) }
    @edges = edges.map do |l,g,d|
      Edge.new(@nodes[g], @nodes[d], l).tap do |edge|
        @nodes[g].outbound << edge
        @nodes[d].inbound << edge
      end
    end
  end

  def verbs
    @nodes.select(&:is_verb?)
  end

  def points(candidate_verbs)
    result_points = []
    result_frames = []
    verbs.each do |node|
      frames = candidate_verbs[node.lemma].map { |f| Frame.new(upgrade_frame(f)) }

      frames.each do |frame|
        result_frames << { string: frame.pos_pattern_string, missing: Frame.relations(frame.pos_pattern_string).empty? }
        matched = true
        match_data = frame.query.map do |relation|
          origin, destination = node.scan(relation)
          if origin.nil? || destination.nil?
            matched = false
            break
          end
          [
            { component: relation.origin_attributes, match: origin },
            { component: relation.destination_attributes, match: destination }
          ]
        end
        next if matched == false || match_data.nil? || match_data.empty?
        match_data = match_data.flatten.uniq { |e| e[:match] }
        result_points << Point.new(frame, match_data)
      end
    end
    [result_points, result_frames]
  end

  def upgrade_frame(frame)
    frame['syntax'].map do |c|
      c['value'] ? "#{c['name']}.#{c['value']}" : c['name']
    end.join(" ")
  end
end
