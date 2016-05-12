class Discussion < ActiveRecord::Base
  has_many :comments

  def root_comments
    comments.where(parent: nil).order('votes DESC')
  end

  def topic_text
    comments.pluck(:text)
      .join(" ")
      .gsub(/[^\w']/, " ")
      .gsub(/\s+/, " ")
      .downcase[0..60000]
  end
end
