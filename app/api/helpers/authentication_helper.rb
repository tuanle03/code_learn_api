module Helpers::AuthenticationHelper
  extend Grape::API::Helpers

  def authenticate_user!
    error!('Unauthorized. Invalid or expired token.', 401) unless current_user
  end

  def current_user
    @current_user ||=
      begin
        token = request.headers['Authorization'].split(' ').last
        User.find_by(id: JWT.decode(token, Rails.application.credentials.devise_jwt_secret_key)[0]['user_id']) if token
      rescue JWT::DecodeError
        nil
      end
  end

end
