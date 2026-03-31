source "https://rubygems.org"

# Use the stable Rails 8.0 branch for compatibility with Ruby 3.3
gem "rails", "~> 8.1.3"

# Use postgresql as the database
gem "pg", "~> 1.1"

# Use the Puma web server
gem "puma", ">= 6.0"

# Windows/WSL compatibility for timezones
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Rails 8 high-performance defaults
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Boot performance
gem "bootsnap", require: false

# Deployment and optimization
gem "kamal", require: false
gem "thruster", require: false

# Active Storage variants
gem "image_processing", "~> 1.2"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ]
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end
