# frozen-string-literal: true

require 'rack'
require 'puma'
require 'roda'

module Rodbot
  class Services
    class App
      include Rodbot::Concerns::Memoize

      class << self
        include Rodbot::Concerns::Memoize

        # URL (including port) to reach the app service locally
        #
        # @return [String] URL
        memoize def url
          [
            (ENV['RODBOT_APP_URL'] || 'http://localhost'),
            Rodbot.config(:port)
          ].join(':')
        end
      end

      def tasks(**)
        puts "Starting app service on http://#{bind.join(':')}"
        [method(:run)]
      end

      private

      def run
        Dir.chdir(Rodbot.env.root)
        Puma::Server.new(app, nil, options).tap do |server|
          server.add_tcp_listener(*bind)
          server.app = ::Rack::CommonLogger.new(app, logger)
        end.run.join
      end

      memoize def bind
        [
          (ENV['RODBOT_APP_HOST'] || 'localhost'),
          Rodbot.config(:port)
        ]
      end

      memoize def app
        ::Rack::Builder.parse_file(Rodbot.env.root.join('config.ru').to_s)
      end

      def options
        {
          lowlevel_error_handler: method(:lowlevel_error_handler),
          log_writer: Puma::LogWriter.null,
          min_threads: Rodbot.config(:app, :threads).min,
          max_threads: Rodbot.config(:app, :threads).max
        }
      end

      memoize def logger
        Rodbot::Log.logger('app')
      end

      def lowlevel_error_handler(error)
        logger.error("#{error.message}: #{error.backtrace.first}")
        [500, {}, ['Oops!']]
      end

    end
  end
end
