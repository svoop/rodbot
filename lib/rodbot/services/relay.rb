# frozen-string-literal: true

using Rodbot::Refinements

module Rodbot
  class Services
    class Relay

      # URL (including port) to reach the given relay service locally
      #
      # @param name [Symbol] relay service
      # @return [String] URL
      def self.url(name)
        (@url ||= {})[name] ||= [
          (ENV["RODBOT_RELAY_URL_#{name.upcase}"] || 'http://localhost'),
          Rodbot.config(:port) + 1 + Rodbot.config(:plugin).keys.index(name)
        ].join(':')
      end

      def tasks(only: nil)
        Rodbot.plugins.extend_relay
        extensions = Rodbot.plugins.extensions[:relay]
        extensions.select! { _1 == only.to_sym } if only
        fail Rodbot::RelayError, "no matching relay plugin configured" if extensions.none?
        extensions.map do |name, path|
          puts "Starting relay service extension #{name}"
          path.constantize.new.loops
        end.flatten
      end

    end
  end
end
