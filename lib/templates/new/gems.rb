# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rodbot', '~> 0'

group :matrix, optional: true do
  gem 'matrix_sdk', '~> 2'
end

group :slack, optional: true do
  gem 'slack-ruby-client', '~> 2'
  gem 'async-websocket', '~> 0.8.0'  # see https://github.com/slack-ruby/slack-ruby-client/blob/720b75fe7eda964e3da61bf442532baa66c2927c/lib/slack/real_time/concurrency/async.rb#L137
end

group :redis, optional: true do
  gem 'redis', '~> 5'
end

group :otp, optional: true do
  gem 'rotp', '~> 6'
end
