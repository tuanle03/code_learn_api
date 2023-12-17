require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'generate_jwt' do
    it 'generates a valid JWT token' do
      user = create(:user) # Use FactoryBot to create a user

      jwt_token = user.generate_jwt

      decoded_token = JWT.decode(jwt_token, Rails.application.credentials.devise_jwt_secret_key, true, algorithm: 'HS256')
      expect(decoded_token[0]['user_id']).to eq(user.id)
    end
  end
end
