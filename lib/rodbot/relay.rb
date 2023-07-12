# frozen-string-literal: true

require 'digest'

module Rodbot

  # Base class for relay extensions
  class Relay

    # Loops which will be called by the relay service
    #
    # @abstract
    # @return [Array<Proc>]
    def loops
      fail(Rodbot::RelayError, "loops method is not implemented")
    end

#   # @abstract
#   def login
#     fail(Rodbot::RelayError, "login not necessary")
#   end
#
#   # @abstract
#   def logout
#     fail(Rodbot::RelayError, "logout not possible")
#   end

    private

    # @return [Symbol] name of the relay extension
    def name
      self.class.to_s.split('::')[-2].downcase.to_sym
    end

    # @see {Rodbot::Relay.bind}
    # @return [String] designated "IP:port"
    def bind
      self.class.bind_for name
    end

    # Determine where to bind a relay extension
    #
    # @param name [Symbol, String] name of the relay extension e.g. +:matrix+
    # @return [Array] designated [IP, port]
    def self.bind_for(name)
      base_port = Rodbot.config(:app, :port) + 1
      if Rodbot.env.split?
        ['0.0.0.0', base_port]
      else
        ['localhost', base_port + Rodbot.config(:plugin).keys.index(name)]
      end
    end

  end
end
