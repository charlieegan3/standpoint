class Point
  def initialize(frame, match_data)
    @nodes = match_data.map { |e| e[:match].tree }.flatten.uniq
    @match_nodes = match_data.map { |e| e[:match] }
    @matches = match_data.map do |e|
      e.merge(matched_nodes: (e[:match].tree - (@match_nodes - [e[:match]])))
    end
    @frame = frame
  end

  def inspect
    puts @frame.pattern_string
    puts node_string
    @matches.each do |match|
      print '"' + match_string(match) + '"'
      print "(" + match_semantics(match) + ")" if match_semantics(match)
      puts
    end
  end

  def node_string
    @nodes.sort_by(&:index).map(&:word).join(" ")
  end

  def match_string(match)
    match[:matched_nodes].sort_by(&:index).map(&:word).join(", ")
  end

  def match_semantics(match)
     match[:component][:semantics]
  end

  def to_hash
    {
      frame: @frame.pattern_string,
      string: node_string,
      matche_components: @matches.map { |e| { semantics: match_semantics(e), words: match_string(e) } }
    }
  end
end
