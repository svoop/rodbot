# frozen_string_literal: true

module Rodbot
  class Plugins
    class GithubWebhook
      module App

        class Routes < ::App
          DEFAULT_HANDLER = ->(request) do
            if request.env['HTTP_X_GITHUB_EVENT'] == 'workflow_run'
              json = JSON.parse(request.body.read)
              project = json.dig('repository', 'full_name')
              status = json.dig('workflow_run', 'status')
              status = json.dig('workflow_run', 'conclusion') if status == 'completed'
              emoji = case status
                when 'requested' then '🟡'
                when 'success' then '🟢'
                when 'failure' then '🔴'
                else '⚪️'
              end
              [emoji, project, status.gsub('_', ' ')].join(' ')
            end
          end

          route do |r|
            r.post '' do
              r.halt 200 if request.env['HTTP_X_GITHUB_EVENT'] == 'ping'
              r.halt 401 unless authorized?
              handler = Rodbot.config(:plugin, :github_webhook, :handler) || DEFAULT_HANDLER
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
            Rodbot.config(:plugin, :github_webhook, :secret_tokens).to_s.split(':').any? do |secret|
              signature = 'sha256=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, request.body.read)
              request.body.rewind
              ::Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE_256'])
            end
          end

        end
      end
    end
  end
end
