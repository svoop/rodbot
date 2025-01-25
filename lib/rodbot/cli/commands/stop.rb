# frozen_string_literal: true

module Rodbot
  class CLI
    module Commands
      class Stop < Rodbot::CLI::Command
        desc 'Stop Rodbot'

        def rescued_call(**)
          Rodbot::Services.new.interrupt
        end
      end
    end
  end
end
