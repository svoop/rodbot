# frozen_string_literal: true

module Rodbot
  class Plugins
    class Otp
      module App

        module RequestMethods
          def valid_otp?
            !!@totp.verify(password, drift_behind: Rodbot.config(:otp, :drift).to_i)
          end

          def require_valid_otp!
            halt [401, {}, ['Unauthorized']] unless valid_otp?
          end

          private

          def totp
            @totp ||= ROTP::TOTP.new(Rodbot.config(:otp, :secret), issuer: 'Rodbot')
          end

          def password
            arguments = arguments.sub(/\s*(\d{6})\s*\z/, '')
            $1
          end
        end

      end
    end
  end
end
