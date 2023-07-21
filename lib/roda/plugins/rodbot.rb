# frozen-string-literal: true

using Rodbot::Refinements

class Roda
  module RodaPlugins

    module Rodbot
      def self.configure(app)
        ::Rodbot.plugins.extensions[:app].each do |name, path|
          app.run(name) { "#{path}/routes".constantize }
        rescue NameError
        end
      end

      module RequestMethods
        def arguments
          params['arguments']
        end
      end
    end

    register_plugin :rodbot, Rodbot

  end
end
