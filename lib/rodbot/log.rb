# frozen-string-literal: true

module Rodbot

  # Log facilities
  class Log

    # Default logger
    attr_reader :default_logger

    # Black hole logger
    attr_reader :null_logger

    def initialize
      @default_logger = self.class.logger('rodbot')
      @null_logger = Logger.new(File::NULL)
    end

    # Add a log entry to the default log
    #
    # @note Use the +Rodbot.log+ shortcut to access this method!
    #
    # @param message [String] log message
    # @param level [Integer] any log level from {Logger}
    def log(message, level: Logger::INFO)
      @default_logger.log(level, message)
    end

    # Create a logger instance for the given scope
    #
    # @param progname [String] progname used as default scope
    def self.logger(progname)
      Logger.new(Rodbot.config(:log, :to), progname: progname).tap do |logger|
        logger.level = Rodbot.config(:log, :level)
      end
    end

    # Whether currently configured to log to a std device (+STDOUT+ or +STDERR+)
    #
    # @return [Boolean]
    def self.std?
      [STDOUT, STDERR].include? Rodbot.config(:log, :to)
    end

    # Simple wrapper to decorate a logger for use with $stdout and $stderr
    class LoggerIO

      # @ param logger [Logger] logger instance
      # @ param level [Integer] any log level from +Logger+
      def initialize(logger, level)
        @logger, @level = logger, level
      end

      # Write to the log
      #
      # @param message [String] log entry to add
      def write(message)
        @logger.log(@level, message.strip)
      end

      # Swallow any other method such as +sync+ or +flush+
      def method_missing(*)
      end
    end

  end
end
