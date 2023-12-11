class Discussion < ApplicationRecord
  belongs_to :user
  has_many :comments, as: :linked_object
end
