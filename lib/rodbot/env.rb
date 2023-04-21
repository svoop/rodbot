# frozen-string-literal: true

module Rodbot

  # Environment the bot is living in
  #
  # @note Use the +Rodbot.env+ shortcut to access these methods!
  class Env

    # Supported environments
    ENVS = %w(production development test).freeze

    # @return [Pathname] root directory
    attr_reader :root

    # @return [Pathname] root directory
    attr_reader :tmp

    # @return [Pathname] gem root directory
    attr_reader :gem

    # @return [String] current environment - any of {ENVS}
    attr_reader :current

    # @param root [Pathname, String] root path (default: current directory)
    def initialize(root: nil)
      @root = root ? Pathname(root).realpath : Pathname.pwd
      @tmp = @root.join('tmp')
      @gem = Pathname(__dir__).join('..', '..').realpath
      @current = ENV['RODBOT_ENV']
      @current = 'development' unless ENVS.include? @current
    end

    # @!method production?
    # @!method development?
    # @!method test?
    #
    # Inquire the env based on RODBOT_ENV
    #
    # @return [Boolean]
    ENVS.each do |env|
      define_method "#{env}?" do
        env == current
      end
    end

    # Whether the current environment is split.
    #
    # @return [Boolean] +true+ if every service runs it its own container or
    #   +false+ if all services run in the same container (or on the host)
    def split?
      ENV['RODBOT_SPLIT'] == 'true'
    end

  end
end
