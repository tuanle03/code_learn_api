class Feedback < ApplicationRecord
  belongs_to :user
  belongs_to :post

  has_many :comments, as: :linked_object
  has_many :votes, as: :linked_object

  def total_likes
    votes.liked.count
  end

  def total_comments
    comments.count
  end
end
