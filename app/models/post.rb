class Post < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  enum status: { approved: 'approved', pending: 'pending', rejected: 'rejected' }

  validates :title, presence: true

  belongs_to :user
  has_many :feedbacks, dependent: :destroy

  scope :newest, -> { order(created_at: :desc) }
  scope :oldest, -> { order(created_at: :asc) }
  scope :most_viewed, -> { order(total_view: :desc) }
  scope :approved, -> { where(status: 'approved') }
  scope :pending, -> { where(status: 'pending') }
  scope :rejected, -> { where(status: 'rejected') }
  scope :total, -> { count }
end
