source 'https://rubygems.org'

gem 'rodbot', '~> 0'

group :matrix, optional: true do
  gem 'matrix_sdk', '~> 2'
end

group :redis, optional: true do
  gem 'redis', '~> 5'
end

group :otp, optional: true do
  gem 'rotp', '~> 6'
end
