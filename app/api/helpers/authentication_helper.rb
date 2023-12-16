module Helpers::AuthenticationHelper
  extend Grape::API::Helpers

  def process_token
    return unless request.headers['Authorization']

    payload = JWT.decode(request.headers['Authorization'].split(' ')[1], Rails.application.credentials.devise_jwt_secret_key).first
    @current_user_id = payload['user_id']
  rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError
    head :unauthorized
  end

  def authenticate_user!(options = {})
    head :unauthorized unless signed_in?
  end

  def current_user
    @current_user ||= super || User.find(@current_user_id)
  end

  def signed_in?
    @current_user_id.present?
  end
end
