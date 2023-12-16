class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :linked_object, polymorphic: true

  validates :body, presence: true
  validates :user_id, presence: true
  validates :linked_object_id, presence: true
  validates :linked_object_type, presence: true

  def self.create_comment(user, linked_object, body)
    comment = Comment.new
    comment.user = user
    comment.linked_object = linked_object
    comment.body = body
    comment.save
    comment
  end

  def self.delete_comment(user, comment)
    if user == comment.user
      comment.destroy
      return true
    end
    false
  end
end
