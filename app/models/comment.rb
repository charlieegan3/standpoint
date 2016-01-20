class Comment < ActiveRecord::Base
  belongs_to :parent, class_name: 'Comment'
end
