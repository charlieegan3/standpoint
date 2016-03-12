module Condense
  def self.condense_group(group)
    new_group = []
    merged = []
    group.uniq.combination(2).each do |s1, s2|
      s1 = s1.downcase.gsub(/[^\s\w']/, "").strip
      s2 = s2.downcase.gsub(/[^\s\w']/, "").strip
      res = Differ.diff_by_word(s1, s2).to_s.gsub('"', "").gsub(" >> ", "|")
      if res.match(/\-|\+/) || res.scan(/\{[\w\|\s]+\}/).size > 2
        new_group += [s1, s2]
      else
        merged += [s1, s2]
        new_group << merge_diff_groups(res)
      end
    end
    (new_group - merged).uniq.map { |s| present_matched_string(s) }
  end

  def self.merge_diff_groups(string)
    match = string.scan(/\{.+\} \{.+\}/).first
    return string if match.nil?
    g1, g2 = match.split("} {").map { |e| e.gsub(/\{|\}/, "").split("|") }
    replacement = g1.zip(g2).map { |g| g.join(" ") }.join("|")
    string.gsub(match, "{#{replacement}}")
  end

  def self.present_matched_string(string)
    string[0].upcase + string[1..-1] + "."
  end
end
