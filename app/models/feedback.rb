class Feedback < ApplicationRecord
  belongs_to :user

  has_many :comments, as: :linked_object
  has_many :votes, as: :linked_object
end
