class Follow < ApplicationRecord
  belongs_to :following_user, class_name: 'User', foreign_key: 'following_user_id'
  belongs_to :followed_user, class_name: 'User', foreign_key: 'followed_user_id'

  validates :following_user_id, uniqueness: { scope: :followed_user_id }

  def self.toggle_follow_status(following_user_id, followed_user_id)
    existing_follow = Follow.find_by(following_user_id: following_user_id, followed_user_id: followed_user_id)

    if existing_follow
      existing_follow.update(status: !existing_follow.status)
    else
      Follow.create(following_user_id: following_user_id, followed_user_id: followed_user_id, status: true)
    end
  end
end
