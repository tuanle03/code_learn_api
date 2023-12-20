class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :linked_object, polymorphic: true

  validates :content, presence: true
  validates :user_id, presence: true
  validates :linked_object_id, presence: true
  validates :linked_object_type, presence: true

  scope :approved, -> { where(status: 'approved') }

end
