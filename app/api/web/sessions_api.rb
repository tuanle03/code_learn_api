module API
  class Web::SessionsAPI < Grape::API
    namespace :sessions do
      desc 'Sign in and retrieve JWT token'
      params do
        requires :email, type: String, desc: 'User email'
        requires :password, type: String, desc: 'User password'
      end
      post 'sign_in' do
        user = User.find_for_database_authentication(email: params[:email])
        if user && user.valid_password?(params[:password])
          token = user.generate_jwt
          status 200
          {
            success: true,
            token: token,
          }
        else
          status 401
          {
            success: false,
            message: 'Invalid email or password',
          }
        end
      end

      desc 'Sign out and revoke JWT token'
      delete 'sign_out' do
        authenticate_user!
        current_user.revoke_jwt(request.headers['Authorization'])
        status 200
        {
          success: true,
          message: 'Signed out successfully',
        }
      end
    end
  end
end
