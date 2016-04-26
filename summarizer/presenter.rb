# presenter.rb
#
# This module implements the clean and format methods. Given a string such
# as “, abortion is a right - ” it will output “Abortion is a right.”.
# Every extract is cleaned using the methods defined here before being
# included as part of a summary.

module Presenter
  def self.format(string, topics, question=false)
    highlight(clean(string, question), topics)
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
      .gsub(/'([^tmlsrvd])/, '\1')
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

  def self.highlight(string, topics)
    string = string.gsub("|", "<strong> or </strong>")
      .gsub("{", "<strong> (</strong>")
      .gsub("}", "<strong>) </strong>")
    topic_regex = topics.sort_by(&:length).reverse.join("|")
    string.scan(/#{topic_regex}/i).each { |match| string.gsub!(/(^|\W)#{match}(\W)/, '\1' + "<code>#{match}</code>" + '\2') }
    string.strip
  end
end
