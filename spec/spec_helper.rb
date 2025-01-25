# frozen_string_literal: true

gem 'minitest'

require 'debug'
require 'pathname'
require 'ostruct'

require 'rack'
require 'roda'

def spec_dir
  Pathname(__dir__)
end

require 'minitest/autorun'
require spec_dir.join('..', 'lib', 'rodbot')

require 'minitest/flash'
require 'minitest/focus'
require 'minitest/substitute'

class Minitest::Spec
  class << self
    alias_method :context, :describe
  end
end

def app_request(url, verb: :get, env: {})
  path, query = url.split('?')
  env['PATH_INFO'] = path
  env['QUERY_STRING'] = query
  env['REQUEST_METHOD'] ||= verb.to_s.upcase
  env['SCRIPT_NAME'] ||= ''
  App.app.call(env).then do |response|
    OpenStruct.new(status: response[0], body: response[2].join)
  end
end

$LOAD_PATH.prepend spec_dir.join('..', 'lib')   # required for Guard
ENV['RODBOT_ENV'] = 'test'
ENV['RODBOT_CREDENTIALS_DIR'] = spec_dir.join('fixtures', 'credentials').to_s
ENV['TEST_CREDENTIALS_KEY'] = spec_dir.join('fixtures', 'credentials', 'test.key').read
ENV['NO_COLOR'] = 'true'

Rodbot.boot(root: spec_dir.join('..', 'lib', 'templates', 'new'))
Rodbot.instance_variable_set(:@config, Rodbot::Config.new(spec_dir.join('rodbot.rb')))
Rodbot::Rack.boot(::Rack::Builder.new)
