# frozen_string_literal: true

require 'appsignal/integrations/grape'
require 'grape-swagger'
require 'grape_logging'

# Grape::Validations.register_validator('length', Validators::LengthValidator)
# Grape::Validations.register_validator('numeric', Validators::NumericValidator)
# Grape::Validations.register_validator('gte_date', Validators::GteDateValidator)

# All the API module are defined in this file.
class ApplicationAPI < Grape::API
  format :json
  # error_formatter :json
  # formatter :json, JsonFormatter
  # default_error_formatter :json

  helpers ::Helpers::AuthenticationHelper

  before do
    process_token
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
