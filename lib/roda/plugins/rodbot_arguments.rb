class Roda
  module RodaPlugins

    module RodbotArguments
      module RequestMethods
        def arguments
          params['arguments']
        end
      end
    end

    register_plugin :rodbot_arguments, RodbotArguments

  end
end
