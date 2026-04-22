# frozen_string_literal: true

source "https://rubygems.org"

gemspec

group :toolbox, optional: true do
  gem 'minitest-difftastic'
  gem 'minitest-flash'
  gem 'guard'
  gem 'guard-minitest'
  gem 'yard'
end
