# frozen_string_literal: true

module Rodbot
  class Plugins
    class Hal
      module App

        class Routes < ::App
          route do |r|
            r.root do
              response['Content-Type'] = 'text/markdown; charset=utf-8'
              <<~END
                [🔴](https://www.youtube.com/watch?v=ARJ8cAGm6JE) I'm sorry [[SENDER]], I'm afraid I can't do that.
              END
            end
          end
        end

      end
    end
  end
end
