# frozen-string-literal: true

module Rodbot
  class CLI
    module Commands
      class New < Rodbot::CLI::Command
        desc 'Create a new Rodbot scaffold in PATH'
        argument :path, required: true, desc: 'Root directory of the new bot'
        example [
          'my_awesome_bot'
        ]

        def rescued_call(path:, **)
          Rodbot::Generator
            .new(Rodbot.env.gem.join('lib', 'templates', 'new'))
            .write(Pathname(path))
        end
      end
    end
  end
end
