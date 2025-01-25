# frozen_string_literal: true

module Routes
  class Help < App

    route do |r|

      # GET /help
      r.root do
        response['Content-Type'] = 'text/markdown; charset=utf-8'
        <<~END
          [[SENDER]] I'm Rodbot, what can I do for you today?

          * `!ping` – check whether I'm listening
        END
      end

    end

  end
end
