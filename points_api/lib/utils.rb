module Utils
  def self.chunk_text(chunk_length, text)
    text.gsub!(/([a-z]\.)([A-Z])/, '\1 \2')
    lines = text.split(/$|\. /)

    things=[].tap do |chunks|
      chunks << ""
      until lines.empty? do
        chunks << "" if (chunks.last + lines.first).length > chunk_length
        chunks[-1] += ". " + lines.shift
      end
    end
  end

  def self.clean_text(text)
    text.encode(Encoding.find('UTF-8'), { invalid: :replace, undef: :replace, replace: ''})
        .gsub(/[^\w\s\n\.,\(\)\{\}\]\["'\$£;:\-&]/, " ").gsub('"', '')
  end

  def self.sentence_contains_topic(sentence, topics)
    string = sentence.first.map { |t|t['word'] }.join.downcase
    topics.each do |t|
      return true if string.include? t
    end
    false
  end
end
