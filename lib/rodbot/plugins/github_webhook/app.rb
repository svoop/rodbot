# frozen_string_literal: true

module Rodbot
  class Plugins
    class GithubWebhook
      module App

        class Routes < ::App
          route do |r|
            r.post '' do
              r.halt 200 if request.env['HTTP_X_GITHUB_EVENT'] == 'ping'
              r.halt 400 unless request.env['HTTP_X_GITHUB_EVENT'] == 'workflow_run'
              r.halt 401 unless authorized?
              json = JSON.parse(request.body.read)
              project = json.dig('repository', 'full_name')
              status = json.dig('workflow_run', 'status')
              status = json.dig('workflow_run', 'conclusion') if status == 'completed'
              Rodbot.say [emoji_for(status), project, status.gsub('_', ' ')].join(' ')
              r.halt 200
            end
          end

          private

          def authorized?
            Rodbot.config(:plugin, :github_webhook, :secret_tokens).to_s.split(':').any? do |secret|
              signature = 'sha256=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, request.body.read)
              request.body.rewind
              ::Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE_256'])
            end
          end

          def emoji_for(status)
            case status
              when 'requested' then '🟡'
              when 'success' then '🟢'
              when 'failure' then '🔴'
              else '⚪️'
            end
          end

        end
      end
    end
  end
end
