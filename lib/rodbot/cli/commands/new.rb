module Rodbot
  module CLI
    module Commands
      class New < Dry::CLI::Command
        desc 'Create a new Rodbot scaffold in PATH'
        argument :path, required: true, desc: 'Root directory of the new bot'
        example [
          'my_awesome_bot'
        ]

        def call(path:, **)
          # TODO:
        end
      end
    end
  end
end
