# frozen_string_literal: true

require 'dry/cli'
require 'dry/credentials'

require 'zeitwerk'
loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/templates")
loader.inflector.inflect 'cli' => 'CLI'
loader.setup

module Rodbot
  extend Dry::Credentials

  class << self
    extend Forwardable

    # Shortcuts +Rodbot.env+ and +Rodbot.config+
    def_delegator 'Rodbot::Env', :itself, :env
    def_delegator 'Rodbot::Config', :config, :config

    # Boot the bot
    def boot
      Rodbot::Config.read Rodbot.env.root.join('config', 'rodbot.rb')
    end
  end
end
