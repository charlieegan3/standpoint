class Comment < ActiveRecord::Base
  has_many :children, class_name: "Comment", foreign_key: "parent_id"
  belongs_to :parent, class_name: 'Comment'

  def domain
    source.split("/")[2]
  end

  def summary_text
    text = body.split(/\s+/).take(20).join(" ")
    if text.length < 30
      text += "Comment: "
      text += children.first.body.split(/\s+/).take(20).join(" ")
    end
    if text.length > 70
      text = text[0..67] + "..."
    end
    return text
  end
end
