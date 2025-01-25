# frozen_string_literal: true

module Rodbot
  class Plugins
    class GitlabWebhook
      module App

        class Routes < ::App
          DEFAULT_HANDLER = ->(request) do
            json = JSON.parse(request.body.read)
            if json['object_kind'] == 'pipeline'
              project = json.dig('project', 'path_with_namespace')
              status = json.dig('object_attributes', 'detailed_status')
              emoji = case status
                when 'running' then '🟡'
                when 'passed' then '🟢'
                when 'failed' then '🔴'
                else '⚪️'
              end
              [emoji, project, status.gsub('_', ' ')].join(' ')
            end
          end

          route do |r|
            r.post '' do
              r.halt 401 unless authorized?
              handler = Rodbot.config(:plugin, :gitlab_webhook, :handler) || DEFAULT_HANDLER
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
            Rodbot.config(:plugin, :gitlab_webhook, :secret_tokens).to_s.split(':').include?(request.env['HTTP_X_GITLAB_TOKEN'])
          end

        end
      end
    end
  end
end
