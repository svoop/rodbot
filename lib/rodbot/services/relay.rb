# frozen-string-literal: true

using Rodbot::Refinements

module Rodbot
  class Services
    class Relay

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
