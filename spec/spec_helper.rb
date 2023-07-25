gem 'minitest'

require 'debug'
require 'pathname'
require 'rack'

def spec_dir
  Pathname(__dir__)
end

require 'minitest/autorun'
require spec_dir.join('..', 'lib', 'rodbot')

require 'minitest/sound'
Minitest::Sound.success = spec_dir.join('sounds', 'success.mp3').to_s
Minitest::Sound.failure = spec_dir.join('sounds', 'failure.mp3').to_s

require 'minitest/focus'

class MiniTest::Spec
  class << self
    alias_method :context, :describe
  end
end

def with(subject, substitute, on: self, assign: '=')
  memo = on.instance_eval subject.to_s
  on.instance_eval "#{subject}#{assign} substitute"
  yield
  on.instance_eval "#{subject}#{assign} memo"
end

$LOAD_PATH.prepend spec_dir.join('..', 'lib')   # required for Guard
ENV['RODBOT_ENV'] = 'test'
ENV['RODBOT_CREDENTIALS_DIR'] = spec_dir.join('fixtures', 'credentials').to_s
ENV['TEST_CREDENTIALS_KEY'] = spec_dir.join('fixtures', 'credentials', 'test.key').read
ENV['NO_COLOR'] = 'true'
Rodbot.boot(root: spec_dir.join('..', 'lib', 'templates', 'new'))
Rodbot::Rack.boot(::Rack::Builder.new)
