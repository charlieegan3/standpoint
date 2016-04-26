# condense.rb
#
# This module implements a means of merging strings that are similar. Making
# use of the differ gem, this can take a pair of strings
# e.g. "Abortion is not a right" and "Abortion is a right" and output:
# "Abortion is {not} a right".

module Condense
  def self.condense_group(group)
    return group if group.size < 2
    new_group = []
    merged = []
    pairs = group.uniq.combination(2).sort_by { |p1, p2| (p1.length - p2.length).abs }
    pairs.each do |s1, s2|
      originals = [s1, s2]
      next unless ((merged + new_group) & originals).empty?
      s1 = s1.downcase.gsub(/[^\s\w']/, "").strip
      s2 = s2.downcase.gsub(/[^\s\w']/, "").strip
      res = Differ.diff_by_word(s1, s2).to_s.gsub('"', "").gsub(" >> ", "|")
      change_count = res.scan(/\-|\+/).size
      group_count = res.scan(/\{[\w\|\s'\+\-]+\}/).size
      shared = (s1.split(/\s/) & s2.split(/\s/))
      if shared.empty? || group_count > 2 || change_count > 1 || change_count + group_count > 2
        new_group += originals
      else
        merged += originals
        new_group << merge_diff_groups(res)
      end
    end
    new_group += group - ((new_group + merged))
    (new_group - merged).uniq
      .map { |s| present_matched_string(s) }
      .sort_by { |s| s.index("{") || 1000 }
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
      .gsub(/\s?\|\s?/, "|")
      .gsub("{'t}", "{can't}") #https://en.wiktionary.org/wiki/Category:English_words_suffixed_with_-n%27t
      .gsub("{n't}", "{not}")
      .strip
  end

  def self.present_matched_string(string)
    string.gsub!(" '", "'")
    string[0].upcase + string[1..-1] + "."
  end
end
