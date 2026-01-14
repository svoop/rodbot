# frozen_string_literal: true

module Rodbot
  class Plugins
    class ForgejoWebhook
      module App

        class Routes < ::App
          DEFAULT_HANDLER = ->(request) do
            json = JSON.parse(request.body.read)
            project = json.dig('run', 'repository', 'full_name')
            status = json.dig('run', 'status')
            emoji = case status
              when 'success' then '🟢'
              when 'failure' then '🔴'
              else '⚪️'
            end
            [emoji, project, status.gsub('_', ' ')].join(' ')
          end

          route do |r|
            r.post '' do
              r.halt 401 unless authorized?
              handler = Rodbot.config(:plugin, :forgejo_webhook, :handler) || DEFAULT_HANDLER
              message = handler.call(r)
              if message&.empty?
                r.halt 204
              else
                Rodbot.say message
                r.halt 200
              end
            end
          rescue => error
            r.halt 500, error.message
          end

          private

          def authorized?
            Rodbot.config(:plugin, :forgejo_webhook, :secret_tokens).to_s.split(':').any? do |secret|
              signature = OpenSSL::HMAC.hexdigest('sha256', secret, request.body.read)
              request.body.rewind
              ::Rack::Utils.secure_compare(signature, request.env['HTTP_X_FORGEJO_SIGNATURE'])
            end
          end

        end
      end
    end
  end
end
