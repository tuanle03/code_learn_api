require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CodeLearnApi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    config.generators do |g|
      g.test_framework :rspec
    end
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.

    config.time_zone = 'Hanoi'

    # config.eager_load_paths << Rails.root.join("extras")
    config.eager_load_paths << Rails.root.join('app/api')

    config.before_initialize do
      ENV["BLAZER_USERNAME"] = Rails.application.credentials.dig(:basic_auth, :blazer_username)
      ENV["BLAZER_PASSWORD"] = Rails.application.credentials.dig(:basic_auth, :blazer_password)
    end
  end
end
