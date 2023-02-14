module Rodbot
  module CLI
    module Commands
      class Version < Dry::CLI::Command
        desc "Print version"

        def call(*)
          puts Rodbot::VERSION
        end
      end
    end
  end
end
