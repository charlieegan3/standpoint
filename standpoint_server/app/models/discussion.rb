class Discussion < ActiveRecord::Base
  has_many :comments

  def root_comments
    comments.where(parent: nil).order('votes DESC')
  end

  def point_clusters
    comments.map(&:points)
      .flatten
      .group_by(&:pattern)
      .sort_by { |k, v| v.size }
      .reverse
  end

  def topic_text
    comments.pluck(:text)
      .join(" ")
      .gsub(/[^\w']/, " ")
      .gsub(/\s+/, " ")
      .downcase[0..60000]
  end
end
