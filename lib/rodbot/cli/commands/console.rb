# frozen_string_literal: true

using Rodbot::Refinements

module Rodbot
  class CLI
    module Commands
      class Console < Rodbot::CLI::Command
        desc 'Start the Rodbot console'

        def rescued_call(**)
          Rodbot.boot
          Rodbot::SERVICES.each { "rodbot/services/#{_1}".constantize }
          require 'irb'
          IRB.setup nil
          IRB.conf[:MAIN_CONTEXT] = IRB::Irb.new.context
          require 'irb/ext/multi-irb'
          IRB.irb nil, Rodbot
        end
      end
    end
  end
end
