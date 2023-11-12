# frozen_string_literal: true

require 'forwardable'
require 'pathname'

require 'zeitwerk'
require 'dry/credentials'
require 'logger'

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
# * +Rodbot.db+ -> {Rodbot::Db#db}
# * +Rodbot.log+ -> {Rodbot::Log#log}
# * +Rodbot.request+ -> {Rodbot::Rack#request}
# * +Rodbot.say+ -> {Rodbot::Relay#say}
module Rodbot
  include Rodbot::Constants
  extend Dry::Credentials

  class << self
    extend Forwardable

    attr_reader :env
    def_delegator :@config, :config
    def_delegator :@plugins, :itself, :plugins
    def_delegator :@db, :itself, :db
    def_delegator :@log, :log
    def_delegator 'Rodbot::Rack', :request
    def_delegator 'Rodbot::Relay', :say

    def boot(root: nil)
      @env = Rodbot::Env.new(root: root)
      credentials do
        env Rodbot.env.current
        dir ENV['RODBOT_CREDENTIALS_DIR'] || Rodbot.env.root.join('config', 'credentials')
      end
      @config = Rodbot::Config.new(Rodbot.env.root.join('config', 'rodbot.rb'))
      ENV['TZ'] = @config.config(:time_zone)
      @plugins = Rodbot::Plugins.new
      @db = (db = @config.config(:db)) && Rodbot::Db.new(db)
      @log = Rodbot::Log.new
    end
  end
end

loader.eager_load_namespace(Rodbot::Error)
