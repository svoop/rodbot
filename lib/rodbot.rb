# frozen_string_literal: true

require 'zeitwerk'
require 'dry/credentials'
require 'logger'

require 'matrix_sdk'   # matrix plugin

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect 'cli' => 'CLI'
%w(rodbot/plugins roda templates).each { loader.ignore "#{__dir__}/#{_1}" }
loader.setup

# Rodbot foundation
#
# Once the Rodbot gem has been required, use +boot+ to spin up the foundation:
#
#   Rodbot.boot                          # current directory is root directory
#   Rodbot.boot(root: '/path/to/root')   # explicit root directory
#
# This gives you access to the following shortcuts (in order of loading):
#
# * +Rodbot.env+ -> {Rodbot::Env}
# * +Rodbot.credentials+ -> {Dry::Credentials}
# * +Rodbot.config+ -> {Rodbot::Config#config}
# * +Rodbot.plugins+ -> {Rodbot::Plugins}
# * +Rodbot.log+ -> {Rodbot::Log#log}
module Rodbot
  include Rodbot::Constants
  extend Dry::Credentials

  class << self
    extend Forwardable

    attr_reader :env
    def_delegator :@config, :config, :config
    def_delegator :@plugins, :itself, :plugins
    def_delegator :@log, :log, :log
    def_delegator 'Rodbot::Relay', :say, :say

    def boot(root: nil)
      @env = Rodbot::Env.new(root: root)
      credentials do
        env Rodbot.env.current
        dir ENV['RODBOT_CREDENTIALS_DIR'] || Rodbot.env.root.join('config', 'credentials')
      end
      @config = Rodbot::Config.new(Rodbot.env.root.join('config', 'rodbot.rb'))
      @plugins = Rodbot::Plugins.new
      @log = Rodbot::Log.new
    end
  end
end

loader.eager_load_namespace(Rodbot::Error)
