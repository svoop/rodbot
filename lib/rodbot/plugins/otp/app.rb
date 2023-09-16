# frozen_string_literal: true

require 'rotp'

module Rodbot
  class Plugins
    class Otp
      module App

        module RequestMethods
          include Rodbot::Memoize

          def valid_otp?
            def self.arguments = params['arguments'].sub(/\s*\d{6}\s*\z/, '')
            return false unless password
            return false if Rodbot.db.get(:otp, password)   # already used
            !!if totp.verify(password, drift_behind: Rodbot.config(:otp, :drift).to_i)
              Rodbot.db.set(:otp, password) { true }
            end
          end

          def require_valid_otp!
            halt [401, {}, ['Unauthorized']] unless valid_otp?
          end

          private

          memoize def totp
            secret =  Rodbot.config(:plugin, :otp, :secret)
            fail(Rodbot::PluginError, "OTP secret is not set") unless secret
            ROTP::TOTP.new(secret, issuer: 'Rodbot')
          end

          # Extract (and remove) the password from arguments
          #
          # @return [String, nil] extracted password if any
          memoize def password
            params['arguments']&.match(/\s*(\d{6})\s*\z/)&.captures&.first
          end
        end

      end
    end
  end
end
