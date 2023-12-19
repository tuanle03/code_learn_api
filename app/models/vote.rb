class Vote < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true

  scope :liked, -> { where(status: true) }

  def self.toggle_vote(vote_params, user)
    vote = Vote.find_or_initialize_by(
      linked_object_id: vote_params[:linked_object_id],
      linked_object_type: vote_params[:linked_object_type],
      user_id: user.id
    )

    if vote.status.nil? || vote.status == false
      vote.status = true
    else
      vote.status = false
    end
    vote.save
  end

  private

  def self.vote_params
    params.require(:vote).permit(:linked_object_id, :linked_object_type)
  end
end
