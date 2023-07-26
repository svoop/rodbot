# frozen-string-literal: true

require 'digest'
require 'socket'

module Rodbot

  # Base class for relay extensions
  class Relay

    # Post a message via one or more relay services
    #
    # By default, messages are posted via all relay services which have
    # "say true" configured in their corresponding config blocks. To further
    # narrow it to exactly one relay service, use the +on+ argument.
    #
    # @param message [String] message to post
    # @param on [Symbol, nil] post via this relay service only
    # @return result [Boolean] +false+ if at least one relay refused the
    #   connection, +true+ otherwise
    def self.say(message, on: nil)
      Rodbot.config(:plugin).select do |extension, config|
        config[:say] == true && (!on || extensions == on)
      end.keys.each_with_object(true) do |extension, result|
        Socket.tcp(*bind_for(extension), connect_timeout: 3) do |socket|
          socket.write message
          socket.write "\x04"
        end
        result &&= true
      rescue Errno::ECONNREFUSED
        warn "WARNING: say via relay #{extension} failed as connection was refused"
        result = false
      end
    end

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
