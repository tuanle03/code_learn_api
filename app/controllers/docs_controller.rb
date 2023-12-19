class DocsController < ApplicationController

  http_basic_authenticate_with(
    name: Rails.application.credentials.dig(:basic_auth, :api_username),
    password: Rails.application.credentials.dig(:basic_auth, :api_password),
    only: :index,
  )

  def index
  end
end
