# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rodbot', '~> 0'

group :matrix, optional: true do
  gem 'matrix_sdk', '~> 2'
end

group :slack, optional: true do
  gem 'slack-ruby-client', '~> 2'
  gem 'async-websocket', '~> 0.8.0'
end

group :redis, optional: true do
  gem 'redis', '~> 5'
end

group :otp, optional: true do
  gem 'rotp', '~> 6'
end
