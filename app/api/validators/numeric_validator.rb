# frozen_string_literal: true

# NumericValidator for Grape params
class Validators::NumericValidator < Grape::Validations::Validators::Base
  # rubocop: disable Metrics/MethodLength, Metrics/CyclomaticComplexity
  # Validate numeric
  def validate_param!(param_name, params)
    number = Integer(params[param_name] || 0)

    case @option
    when :non_negative
      validate_non_negative!(param_name, number)
    when :negative
      validate_negative!(param_name, number)
    when :positive
      validate_positive!(param_name, number)
    when :non_zero
      validate_non_zero!(param_name, number)
    else
      error_message = "NumericValidator does not supported this option: #{@option}"
      raise(error_message)
    end
  rescue ArgumentError => e
    raise(e) unless e.message.match?(/invalid value for Integer/)

    raise_grape_validation_error(param_name, I18n.t('validators.invalid_numeric'))
  end
  # rubocop: enable Metrics/MethodLength, Metrics/CyclomaticComplexity

  # Validate non negative, raise exception if invalid
  def validate_non_negative!(param_name, number)
    return unless number.negative?

    raise_grape_validation_error(param_name, I18n.t('validators.invalid_non_negative'))
  end

  # Validate negative, raise exception if invalid
  def validate_negative!(param_name, number)
    return if number.negative?

    raise_grape_validation_error(param_name, I18n.t('validators.invalid_negative'))
  end

  # Validate positive, raise exception if invalid
  def validate_positive!(param_name, number)
    return if number.positive?

    raise_grape_validation_error(param_name, I18n.t('validators.invalid_positive'))
  end

  # Validate non zero, raise exception if invalid
  def validate_non_zero!(param_name, number)
    return if number.nonzero?

    raise_grape_validation_error(param_name, I18n.t('validators.invalid_non_zero'))
  end

  # Raise Grape::Exceptions::Validation
  def raise_grape_validation_error(param_name, message)
    raise(Grape::Exceptions::Validation.new(params: [@scope.full_name(param_name)], message:))
  end
end
