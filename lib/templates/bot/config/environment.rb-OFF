require 'debug' if ENV['BOT_DEBUG']

require 'pathname'
require 'logger'
require 'zeitwerk'
require 'sucker_punch'

# This defines the common environment used by parts of the bot suite. It
# provides the following facilities:
#
# * Root path
# * Environment inquiry
# * Loader (Zeitwerk)
# * Logger
# * Async jobs (sucker_punch)
# * Debugger
module Environment
  extend self

  ENVS = %i(production development test).freeze

  # Root directory
  #
  # @return [Pathname]
  def root
    Pathname(__FILE__).dirname.join('..').realpath
  end

  # @!method production?
  # @!method development?
  # @!method test?
  #
  # Inquire the env based on BOT_ENV
  #
  # @return [Boolean]
  ENVS.each do |env|
    define_method "#{env}?" do
      @env == env
    end
  end

  # Initialize a logger based on BOT_LOG and BOT_LOG_LEVEL
  #
  # @return [Logger]
  def logger
    @logger ||= case log
      when nil then NullLogger.new
      when 'STDOUT' then Logger.new(STDOUT)
      when 'STDERR' then Logger.new(STDERR)
      else Logger.new(log)
    end.tap do |logger|
      logger.level = Logger.const_get(log_level.upcase)
      SuckerPunch.logger = logger
    end
  end

  # Initialize a loader with common presets
  #
  # @return [Zeitwerk::Loader]
  def loader
    Zeitwerk::Loader.new.tap do |loader|
      loader.logger = logger
      loader.push_dir('lib')
    end
  end

  # Perform code asynchronously
  #
  # In order not to interfere with tests, the code is performed synchronously
  # in case the current env is "test"!
  #
  # @example with block
  #   Environment.async do
  #     some_heavy_number_crunching
  #   end
  #
  # @example with proc
  #   Environment.async(-> { some_heavy_number_crunching })
  #
  # @param proc [Proc] either pass a proc to perform...
  # @yield ...or yield the code to perform (ignored if a proc is given)
  def async(proc=nil)
    if test?
      proc ? proc.call : yield
    else
      proc ||= Proc.new   # converts the yielded block to a proc
      Job.perform_async(proc)
    end
  end

  private

  def env
    @env ||= ENV['BOT_ENV'] || 'development'
  end

  def log
    @log ||= ENV['BOT_LOG'] || ('STDOUT' if development?)
  end

  def log_level
    @log_level ||= ENV['BOT_LOG_LEVEL'] || 'info'
  end

  # Generic job which simply calls a proc
  class Job
    include SuckerPunch::Job
    def perform(proc) = proc.call
  end

  # NullLogger which swallows everything
  class NullLogger
    def method_missing(*) end
  end
end
