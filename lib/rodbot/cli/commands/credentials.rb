module Rodbot
  module CLI
    module Commands
      class Credentials < Dry::CLI::Command
        desc 'Edit the credentials for ENVIRONMENT'
        argument :environment, required: true
        example [
          'development'
        ]

        def call(environment:, **)
          # TODO:
        end
      end
    end
  end
end
