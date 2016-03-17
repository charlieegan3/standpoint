module Presenter
  def self.format(string, question=false)
    highlight(clean(string, question))
  end

  def self.clean(string, question=false)
    string = string.strip
      .gsub(/^[^\w\{]+/, "")
      .gsub(/ ?- ?\.?$/, "")
      .gsub(/[\s;\.,]+$/, "")
      .gsub(/\s+(n?[,'\.])/, '\1')
      .gsub("-LRB-", "(").gsub("-RRB-", ")")
      .gsub("( ", "(").gsub(" )", ")")
      .gsub("-LSB-", "[").gsub("-RSB-", "]")
      .gsub("[ ", "[").gsub(" ]", "]").strip
      .gsub("` ", "'")
      .gsub(/'([^tm])/, '\1')
      .gsub(/([^\w\}]+\w{0,1})$/, "")
      .gsub("does not", "doesn't").gsub("can not", "can't").gsub("do not", "don't")
      .gsub(" i ", " I ")
      .gsub(/[^A-Za-z\)\}\]]+$/, "")
    unless question
      string.gsub!(/^(therefor|therefore|then|than|so|to|when|what|that|even if|if|of|even|about|because)\s/i, "")
    end
    string = "#{string[0].upcase}#{string[1..-1]}" rescue binding.pry
    string.gsub!(/[;.]+/, "")
    string.gsub!(/ [:\-]$/, "")
    string.gsub!(" ,", "")
    string = string.strip
    if question
      string += "?" if string.strip[-1] != "?"
    else
      string += "." if string.strip[-1] != "."
    end
    string
  end

  def self.highlight(string)
    string.gsub("|", "<strong> or </strong>")
      .gsub("{", "<strong> (</strong>")
      .gsub("}", "<strong>) </strong>")
  end
end
