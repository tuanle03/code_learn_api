class Discussion < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  belongs_to :user

  has_many :comments, as: :linked_object
  has_many :votes, as: :linked_object

  validates :content, presence: true
  validates :title, presence: true, length: { minimum: 5, maximum: 100 }

  scope :newest, -> { order(created_at: :desc) }
  scope :approved, -> { where(status: 'approved') }
  scope :most_commented, -> {
    joins(:comments)
      .select('discussions.*, COUNT(comments.id) AS comments_count')
      .group('discussions.id')
      .order('comments_count DESC')
  }

  def total_comments
    comments.count
  end

end
