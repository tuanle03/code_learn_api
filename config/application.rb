require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CodeLearnApi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
    
    # Disable freezing of autoload_paths and eager_load_paths for Rails 8.1 compatibility
    # with older gems that try to modify these arrays
    config.autoloader = :zeitwerk
    config.enable_reloading = false unless Rails.env.development?

    config.generators do |g|
      g.test_framework :rspec
    end
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.

    config.time_zone = 'Hanoi'

    # config.eager_load_paths << Rails.root.join("extras")
    # Add app/api to both autoload and eager load paths
    config.autoload_paths += %W[#{config.root}/app/api]
    config.eager_load_paths += %W[#{config.root}/app/api]

    config.before_initialize do
      ENV["BLAZER_USERNAME"] = Rails.application.credentials.dig(:basic_auth, :blazer_username)
      ENV["BLAZER_PASSWORD"] = Rails.application.credentials.dig(:basic_auth, :blazer_password)
    end
  end
end
