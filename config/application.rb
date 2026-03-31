require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module OrchestratorManager
  class Application < Rails::Application
    # CHANGED: 8.1 to 8.0 to match your Ruby 3.3 environment
    config.load_defaults 8.0

    # Standard Rails 8 Autoloading
    config.autoload_lib(ignore: %w[assets tasks])

    # API-only mode: This strips out unnecessary middleware like 
    # cookies and sessions to keep our orchestrator lean.
    config.api_only = true
  end
end
