# frozen_string_literal: true

# LengthValidator for Grape params
class Validators::LengthValidator < Grape::Validations::Validators::Base
  # validate_param! method is required
  def validate_param!(attr_name, params)
    return if params[attr_name].blank?
    return if params[attr_name].length.in?(limited_length)

    raise(Grape::Exceptions::Validation.new(params: [@scope.full_name(attr_name)], message: error_message(attr_name)))
  end

  private

  def limited_length
    case @option
    when Range
      @option
    when Hash
      @option[:minimun]..@option[:maximum]
    when Integer
      @option..@option
    else
      raise(Grape::Exceptions::Validation.new(params: [@scope.full_name(attr_name)], message: 'Length is invalid'))
    end
  end

  def error_message(attr_name)
    case @option
    when Range
      "#{attr_name} length must be in #{@option}"
    when Hash
      "#{attr_name} length must be in #{Integer(@option[:minimun], 10)}..#{Integer(@option[:maximum], 10)}"
    when Integer
      "#{attr_name} length must be #{@option}"
    end
  end
end
