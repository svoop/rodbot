# frozen_string_literal: true

module Rodbot
  class Plugins
    class GitlabWebhook
      module App

        class Routes < ::App
          route do |r|
            r.post '' do
              r.halt 401 unless authorized? request
              json = JSON.parse(request.body.read)
              r.halt 400 unless json['object_kind'] == 'pipeline'
              project = json.dig('project', 'path_with_namespace')
              status = json.dig('object_attributes', 'detailed_status')
              Rodbot.say [emoji_for(status), project, status.gsub('_', ' ')].join(' ')
              r.halt 200
            end
          end

          private

          def authorized?(request)
            Rodbot.config(:plugin, :gitlab_webhook, :secret_tokens).to_s.split(':').include?(request.env['HTTP_X_GITLAB_TOKEN'])
          end

          def emoji_for(status)
            case status
              when 'running' then '🟡'
              when 'passed' then '🟢'
              when 'failed' then '🔴'
              else '⚪️'
            end
          end

        end
      end
    end
  end
end
