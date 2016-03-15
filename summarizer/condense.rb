module Condense
  def self.condense_group(group)
    group.sort_by!(&:length)
    new_group = []
    merged = []
    group.uniq.combination(2).each do |s1, s2|
      s1 = s1.downcase.gsub(/[^\s\w']/, "").strip
      s2 = s2.downcase.gsub(/[^\s\w']/, "").strip
      next unless ((merged + new_group) & [s1, s2]).empty?
      res = Differ.diff_by_word(s1, s2).to_s.gsub('"', "").gsub(" >> ", "|")
      change_count = res.scan(/\-|\+/).size
      group_count = res.scan(/\{[\w\|\s'\+\-]+\}/).size
      shared = (s1.split(/\s/) & s2.split(/\s/))
      if shared.empty? || group_count > 2 || change_count > 1 || change_count + group_count > 2
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
    return format_match_string(string) if match.nil?
    g1, g2 = match.split("} {").map { |e| e.gsub(/\{|\}/, "").split("|") }
    replacement = g1.zip(g2).map { |g| g.join(" ") }.join("|")
    format_match_string(string.gsub(match, " { #{replacement} } "))
  end

  def self.format_match_string(string)
    string.gsub(/\s*\}\s*/, "} ")
      .gsub(/\s*\{\s*/, " {")
      .gsub(/\s+/, " ")
      .gsub(/\+|\-/, "")
  end

  def self.present_matched_string(string)
    string[0].upcase + string[1..-1] + "."
  end
end
