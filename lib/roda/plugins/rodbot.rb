class Roda
  module RodaPlugins

    module Rodbot
      def self.load_dependencies(app)
        app.plugin :multi_run
        app.plugin :environments
        app.plugin :heartbeat
        app.plugin :public
        app.plugin :run_append_slash
        app.plugin :halt
        app.plugin :unescape_path
        app.plugin :render, layout: './layout', views: 'app/views'
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
