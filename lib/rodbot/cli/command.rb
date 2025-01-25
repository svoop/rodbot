# frozen_string_literal: true

module Rodbot
  class CLI
    class Command < Dry::CLI::Command
      option :backtrace, type: :boolean, default: false, desc: "Dump backtrace on errors"

      def call(backtrace:, **args)
        rescued_call(**args)
      rescue => error
        error(error.message) do
          raise error if backtrace
        end
      end

      private

      def error(message)
        STDERR.puts "ERROR: command failed: #{message}"
        yield if block_given?
        exit 1
      end
    end
  end
end
