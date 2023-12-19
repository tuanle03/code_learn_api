# frozen_string_literal: true

require 'appsignal/integrations/grape'
require 'grape-swagger'
require 'grape_logging'

class ApplicationAPI < Grape::API
  format :json

  helpers ::Helpers::AuthenticationHelper
  helpers do
    def unauthorized_error!
      error!('Unauthorized', 401)
    end
  end

  rescue_from Grape::Exceptions::ValidationErrors do |e|
    error!(e, 400)
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    error!(e, 404)
  end

  rescue_from NotImplementedError, TypeError, StandardError do |e|
    status_code = e.respond_to?(:status_code) ? e.status_code : 500
    Appsignal.set_error(e) if status_code == 500
    error!(e, status_code)
  end

  mount WebAPI
end
