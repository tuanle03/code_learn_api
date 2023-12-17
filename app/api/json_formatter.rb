# frozen_string_literal: true
# typed: true

# Custom formatter for Grape API
class JsonFormatter
  class << self
    # Return the response in JSON format
    def call(obj, env)
      case obj
      when ServiceResult
        success_entity = get_success_entity(env)
        to_json(success_entity.represent(success_entity.try(:collection?) ? obj.records : obj.record), env)
      when API::Result
        success_entity = get_success_entity(env)
        to_json(success_entity.represent(obj.data), env)
      else
        to_json(obj, env)
      end
    end

    private

    def to_json(obj, env)
      Grape::Formatter::Json.call(obj, env)
    end

    def get_success_entity(env)
      success_entity = env.dig('grape.routing_args', :route_info).options[:success]
      success_entity || raise(Errors::APIFailures::InvalidSuccessConfigError)
    end
  end
end
