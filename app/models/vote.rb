class Vote < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true

  def self.create_or_update(user_id, vote_params)
    vote = Vote.find_by(user_id: user_id, linked_object_id: vote_params[:linked_object_id], linked_object_type: vote_params[:linked_object_type])
    if vote && vote.status.present?
      vote.update(status: !vote.status)
    else
      vote = Vote.new(vote_params)
      vote.user_id = user_id
      vote.status = true
      vote.save
    end
  end

  private

  def self.vote_params
    params.require(:vote).permit(:linked_object_id, :linked_object_type, :vote_type)
  end
end
