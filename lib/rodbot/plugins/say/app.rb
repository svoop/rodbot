# frozen_string_literal: true

module Rodbot
  class Plugins
    class Say
      module App

        module InstanceMethods
          def say(message, on: nil)
            Rodbot.config(:plugin).each do |extension, config|
              next unless config[:say] == true && (!on || extension == on)
            end.keys.each |extension|
              Socket.tcp(*Rodbot::Relay.bind_for(extension), connect_timeout: 3) do |socket|
                socket.write message
                socket.write "\x04"
              end
            end
          end
        end

      end
    end
  end
end
