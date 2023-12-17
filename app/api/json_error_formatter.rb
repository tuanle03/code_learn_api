# frozen_string_literal: true
# typed: true

# Custom error formatter for Grape API
class JsonErrorFormatter
  class << self

    ERRORS_MAPPER = {
      StandardError: 'E999',
      'Errors::APIFailures::AccessDeniedError': 'E401',
      'Grape::Exceptions::ValidationErrors': 'E400',
      'Errors::AccessDeniedError': 'E1001',
      'ActiveRecord::RecordNotFound': 'E1002',
      'AASM::InvalidTransition': 'E1003',
      'ActiveModel::Errors': 'E1004',
      ArgumentError: 'E1005',
      'Tpl::Services::Base::InvalidKeyError': 'E1006',
      'NonUpdatable::NonUpdatableError': 'E1007',
      'Errors::StockChecks::AlreadyStartedError': 'E1008',
      'Errors::StockChecks::HasNotStartedError': 'E1009',
      'Errors::StockChecks::AlreadyEndedError': 'E1010',
      'Errors::StockChecks::NotAllLocationsChecked': 'E1011',
      'Errors::OverstockCarts::CheckingProductIsNotUnderstockError': 'E1013',
      'Errors::OverstockCarts::SupplyOverflowError': 'E1014',
      'Errors::OverstockCarts::DiffStockNotMatchedExceedingStockError': 'E1015',
      'Errors::OverstockCarts::NotEnoughStockOnCart': 'E1016',
      'Errors::SharedAccessKeys::InvalidKeyError': 'E1017',
      'Errors::APIFailures::ServiceFailure': 'E1018',
      'Errors::ProductUnits::AlreadyGtinCodeError': 'E1019',
    }.freeze

    private_constant :ERRORS_MAPPER

    # Return the error response in JSON format
    def call(messages, _backtrace, _options, _env, _original_exception)
      error_code = ERRORS_MAPPER[messages.class.to_s.to_sym] || ERRORS_MAPPER[messages.to_s.to_sym]
      error_code ||= ERRORS_MAPPER[:StandardError]

      {
        error: error_code,
        messages: parse_messages(messages).uniq,
        debug: debug_data(messages),
      }.to_json
    end

    # Adding the debug data to the error response
    def debug_data(messages)
      return {} if Rails.env.production?

      {
        inspect: messages.try(:inspect)&.first(100),
        backtrace: messages.try(:backtrace)&.first(30),
      }
    end

    # Return the error messages
    def parse_messages(exception) # rubocop:disable Metrics/MethodLength
      case exception
      when ActiveModel::Errors, Grape::Exceptions::ValidationErrors
        exception.full_messages
      when ActiveRecord::RecordNotFound
        Array(I18n.t('api.errors.not_found', model: exception.model))
      when Errors::APIFailures::ServiceFailure
        exception.errors.full_messages
      when ActiveRecord::RecordInvalid, StandardError
        Array(exception.message)
      when Array
        exception
      else
        Array(exception)
      end
    end
  end
end
