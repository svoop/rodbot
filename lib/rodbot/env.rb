module Rodbot

  # Environment the bot is living in
  #
  # @note Use the +Rodbot.env+ shortcut to access these methods!
  module Env
    extend self

    # Supported environments
    ENVS = %w(production development test).freeze

    # @!method production?
    # @!method development?
    # @!method test?
    #
    # Inquire the env based on RODBOT_ENV
    #
    # @return [Boolean]
    ENVS.each do |env|
      define_method "#{env}?" do
        env == current_env
      end
    end

    # Set the root directory
    #
    # @param dir [Pathname, String] root directory
    def root=(dir)
      @root = Pathname(dir).realpath
    end

    # Get (or guess) the root directory
    #
    # @return [Pathname]
    def root
      @root ||= Pathname.pwd
    end

    # Zeitwerk loader with common presets
    #
    # @return [Zeitwerk::Loader]
    def loader
      @loader ||= Zeitwerk::Loader.new.tap do |loader|
# TODO: add logger
#       loader.logger = logger
        loader.push_dir(root.join('lib'))
        loader.push_dir(root.join('config', 'roda'))
      end
    end

    private

    def current_env
      @current_env ||= ENV['RODBOT_ENV'] if ENVS.include? ENV['RODBOT_ENV']
      @current_env ||= 'development'
    end

  end
end
