class UserRegistrationWithEmailService
  attr_reader :email, :token

  def initialize(email)
    @email = email
  end

  def register
    user = User.find_or_initialize_by email: email
    if user.save
      @token, payload = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)
      user.on_jwt_dispatch(@token, payload)
    end

    user
  end
end
