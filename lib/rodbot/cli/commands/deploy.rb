# frozen_string_literal: true

module Rodbot
  class CLI
    module Commands
      class Deploy < Rodbot::CLI::Command
        desc 'Print the deploy configuration'
        argument :hosting, values: Rodbot::HOSTINGS, required: true, desc: 'Which hosting to use'
        option :split, type: :boolean, default: false, desc: "Whether to split into individual services"

        def rescued_call(hosting:, split:, **)
          dir = [hosting, ('split' if split)].compact.join('-')
          Rodbot::Generator
            .new(Rodbot.env.gem.join('lib', 'templates', 'deploy', dir))
            .display
        end
      end
    end
  end
end
