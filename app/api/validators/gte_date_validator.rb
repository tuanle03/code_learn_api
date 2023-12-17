# frozen_string_literal: true

# GteDateValidator for Grape params
class Validators::GteDateValidator < Grape::Validations::Validators::Base
  FORM_INPUT_TIME = 10.minutes
  private_constant :FORM_INPUT_TIME

  # validate_param! method is required
  def validate_param!(param_name, params)
    case @option
    when :now
      validate_current_date!(param_name, params)
    when Symbol
      validate_greater_than!(param_name, params)
    else
      error_message = I18n.t('validators.un_supported', option: param_name, class: 'GteDateValidator')
      raise(error_message)
    end
  end

  private

  def validate_greater_than!(param_name, params)
    return if params[@option]&.value.blank?
    return if params[param_name].value >= params[@option].value

    raise(Grape::Exceptions::Validation.new(params: [@scope.full_name(param_name)],
      message: I18n.t('validators.invalid_greater_than_date', date: @option)))
  end

  def validate_current_date!(param_name, params)
    return if @option.blank?
    return if params[param_name].value > FORM_INPUT_TIME.ago

    raise(Grape::Exceptions::Validation.new(params: [@scope.full_name(param_name)],
      message: I18n.t('validators.invalid_greater_than_date', date: 'current date')))
  end
end
