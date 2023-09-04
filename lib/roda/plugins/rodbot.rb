class Roda
  module RodaPlugins

    module Rodbot
      class << self
        def load_dependencies(app)
          app.plugin :multi_run
          app.plugin :environments
          app.plugin :heartbeat
          app.plugin :public
          app.plugin :run_append_slash
          app.plugin :halt
          app.plugin :unescape_path
          app.plugin :render, layout: './layout', views: 'app/views'
          load_rodbot_dependencies(app)
        end

        private

        def load_rodbot_dependencies(app)
          ::Rodbot.plugins.extend_app
          ::Rodbot.plugins.extensions[:app].keys.each { app.plugin _1 }
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
