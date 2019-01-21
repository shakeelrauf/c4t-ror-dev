require_relative 'boot'

require 'rails/all'



# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Cashfortrash
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :options, :delete, :put, :patch]
      end
    end
    config.assets.compile = true
    config.assets.precompile += Ckeditor.assets
    config.assets.precompile += %w(ckeditor/* )
    config.autoload_paths += %w(#{config.root}/app/models/ckeditor)
    config.eager_load_paths << Rails.root.join('lib')
    
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
