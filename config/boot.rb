ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.

# Monkey patch Array to prevent freezing errors in Rails 8.1
# This allows older gems to modify frozen autoload_paths arrays
class Array
  alias original_freeze freeze

  def freeze
    # Check if this array is being set as autoload_paths or eager_load_paths
    # by inspecting the call stack
    caller_locations&.any? { |loc| loc.path&.include?('railties') && loc.label&.include?('all_') } ? self : original_freeze
  end
end
