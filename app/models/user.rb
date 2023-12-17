class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Allowlist

  serialize :revoked_tokens, Array

  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable,
    :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :posts, dependent: :destroy
  has_many :feedbacks, dependent: :destroy

  def generate_jwt
    payload = { user_id: id, exp: 1.day.from_now.to_i }
    JWT.encode(payload, Rails.application.credentials.devise_jwt_secret_key)
  end

  def decode_jwt(token)
    JWT.decode(token, Rails.application.credentials.devise_jwt_secret_key)
  end

  def revoke_jwt(token)
    self.revoked_tokens ||= []
    self.revoked_tokens << token
    self.revoked_tokens.uniq!
    save
  end

  def jwt_revoked?(token)
    revoked_tokens.include?(token)
  end
end
