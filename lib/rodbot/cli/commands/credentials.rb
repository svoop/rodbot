# frozen-string-literal: true

module Rodbot
  class CLI
    module Commands
      class Credentials < Rodbot::CLI::Command
        desc 'Edit the credentials for ENVIRONMENT'
        argument :environment, values: Rodbot::Env::ENVS, desc: 'Which environment to edit', required: true
        example [
          'development'
        ]

        def rescued_call(environment:, **)
          Rodbot.credentials.edit! environment
        end
      end
    end
  end
end
