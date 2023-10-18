# frozen-string-literal: true

require 'digest'
require 'socket'
require 'httpx'

module Rodbot

  # Base class for relay extensions
  class Relay
    include Rodbot::Memoize

    class << self

      # Post a message via one or more relay services
      #
      # By default, messages are posted via all relay services which have
      # "say true" configured in their corresponding config blocks. To further
      # narrow it to exactly one relay service, use the +on+ argument.
      #
      # @param message [String] message to post
      # @param on [Symbol, nil] post via this relay service only
      # @return [Boolean] +false+ if at least one relay refused the connection or
      #   +true+ otherwise
      def say(message, on: nil)
        Rodbot.config(:plugin).select do |extension, config|
          config[:say] == true && (!on || extension == on)
        end.keys.inject(true) do |success, extension|
          write(message, extension) && success
        end
      end

      private

      # Write a message to a relay service extension
      #
      # @param message [String] message to post
      # @param extension [Symbol] post via this relay service
      # @return [Boolean] +false+ if the connection was refused or +true+ otherwise
      def write(message, extension)
        uri = URI(Rodbot::Services::Relay.url(extension))
        Socket.tcp(uri.host, uri.port, connect_timeout: 3) do |socket|
          socket.write message
          socket.write "\x04"
        end
        true
      rescue Errno::ECONNREFUSED
        warn "WARNING: say via relay #{extension} failed as connection was refused"
        false
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
    memoize def name
      self.class.to_s.split('::')[-2].downcase.to_sym
    end

    # @see {Rodbot::Relay.bind}
    # @return [String] designated "IP:port"
    memoize def bind
      [
        (ENV["RODBOT_RELAY_HOST"] || 'localhost'),
        Rodbot.config(:port) + 1 + Rodbot.config(:plugin).keys.index(name)
      ]
    end

    # Perform the built-in command or fall back to the app using +request+
    #
    # @param command [String] command to perform
    # @param argument [String, nil] optional arguments
    # @return [String] response as Markdown
    def command(command, argument=nil)
      case command
        when 'ping' then 'pong'
        when 'version' then "rodbot-#{Rodbot::VERSION}"
        else request(command, argument)
      end
    end

    # Perform the command on the app using a GET request
    #
    # @param command [String] command to perform
    # @param argument [String, nil] optional arguments
    # @return [String] response as Markdown
    def request(command, argument=nil)
      response = Rodbot.request(command, params: { argument: argument })
      case response.status
        when 200 then response.body.to_s
        when 404 then "[[SENDER]] I don't know what do do with `!#{command}`. 🤔"
        else fail
      end
    rescue
      "[[SENDER]] I'm having trouble talking to the app. 💣"
    end

  end
end
