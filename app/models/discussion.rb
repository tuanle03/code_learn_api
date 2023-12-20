class Discussion < ApplicationRecord
  belongs_to :user

  has_many :comments, as: :linked_object
  has_many :votes, as: :linked_object

  validates :content, presence: true

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
