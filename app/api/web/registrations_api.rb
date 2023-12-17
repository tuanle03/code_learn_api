module API
  class Web::RegistrationsAPI < Grape::API
    resource :registrations do
      desc 'Create a new user'
      params do
        requires :user, type: Hash do
          requires :email, type: String, desc: 'Email'
          requires :password, type: String, desc: 'Password'
          requires :password_confirmation, type: String, desc: 'Password confirmation'
        end
      end
      post do
        if params[:user][:password] != params[:user][:password_confirmation]
          return error!({ error: 'Password confirmation does not match' }, 400)
        end

        if User.find_by(email: params[:user][:email])
          return error!({ error: 'Email has already been taken' }, 400)
        end

        user = User.new(params[:user])
        if user.save
          token = user.generate_jwt
          status 200
          {
            success: true,
            token: token
          }
        else
          error!({ error: user.errors.full_messages }, 400)
        end
      end
    end
  end
end
