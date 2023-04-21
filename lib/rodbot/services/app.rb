# frozen-string-literal: true

require 'rack'
require 'puma'
require 'roda'

module Rodbot
  class Services
    class App

      def tasks(**)
        puts "Starting app service on http://#{bind.join(':')}"
        [method(:run)]
      end

      private

      def run
        Dir.chdir(Rodbot.env.root)
        Puma::Server.new(app, nil, options).tap do |server|
          server.add_tcp_listener(*bind)
          server.app = Rack::CommonLogger.new(app, logger)
        end.run.join
      end

      def bind
        Rodbot.env.split? ? ['0.0.0.0', 10000] : ['localhost', 10000]
      end

      def app
        @app ||= Rack::Builder.parse_file(Rodbot.env.root.join('config.ru').to_s)
      end

      def options
        {
          lowlevel_error_handler: method(:lowlevel_error_handler),
          log_writer: Puma::LogWriter.null,
          min_threads: Rodbot.config(:app, :threads).min,
          max_threads: Rodbot.config(:app, :threads).max
        }
      end

      def logger
        @logger ||= Rodbot::Log.logger('app')
      end

      def lowlevel_error_handler(error)
        logger.error("#{error.message}: #{error.backtrace.first}")
        [500, {}, ['Oops!']]
      end

    end
  end
end
