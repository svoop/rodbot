# frozen_string_literal: true

module Rodbot
  class CLI
    module Commands
      class Version < Rodbot::CLI::Command
        desc "Print version"

        def rescued_call(**)
          puts Rodbot::VERSION
        end
      end
    end
  end
end
