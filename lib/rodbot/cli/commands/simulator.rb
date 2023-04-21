# frozen-string-literal: true

module Rodbot
  class CLI
    module Commands
      class Simulator < Rodbot::CLI::Command
        desc 'Launch the chat simulator'
        option :sender, default: 'simulator', desc: "Sender to mimick"
        option :raw, type: :boolean, default: false, desc: "Whether to display raw Markdown"

        def rescued_call(sender:, raw:, **)
          Rodbot::Simulator.new(sender, raw: raw).run
        end
      end
    end
  end
end
