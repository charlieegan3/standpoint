class Point
  def initialize(frame, match_data)
    @nodes = match_data.map { |e| e[:match].tree }.flatten.uniq
    @match_nodes = match_data.map { |e| e[:match] }
    @matches = match_data.map do |e|
      e.merge({
        matched_nodes: (e[:match].children - (@match_nodes - [e[:match]])).map(&:tree).flatten.push(e[:match]).uniq
      })

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

  def match_syntax(match)
    match[:component][:pos].inspect
  end

  def to_hash
    {
      frame: @frame.pattern_string,
      bare_frame: @frame.pos_pattern_string,
      string: node_string,
      matched_components: @matches.map { |e|
        {
          words: match_string(e),
          semantics: match_semantics(e),
          syntax: match_syntax(e),
        }
      }
    }
  end
end
