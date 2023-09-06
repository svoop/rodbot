# frozen_string_literal: true

require 'rotp'

module Rodbot
  class Plugins
    class Otp
      module App

        module RequestMethods
          include Rodbot::Memoize

          def valid_otp?
            return false unless password
            return false if Rodbot.db.get(:otp, password)   # already used
            valid = totp.verify(password, drift_behind: Rodbot.config(:otp, :drift).to_i)
            !!if
              Rodbot.db.set(:otp, password) { true }
              true
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
            params['arguments'] = params['arguments']&.sub(/\s*(\d{6})\s*\z/, '')
            $1
          end
        end

      end
    end
  end
end
