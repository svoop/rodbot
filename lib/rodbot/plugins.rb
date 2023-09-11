# frozen-string-literal: true

using Rodbot::Refinements

module Rodbot

  # Interface for bundled and gemified plugins
  class Plugins

    # Required service extensions from plugins
    #
    # @return [Hash] map from extension name (Symbol) to module or class
    #   path (String)
    attr_reader :extensions

    def initialize
      @extensions = {}
    end

    # Extend app service with app components provided by all active plugins
    def extend_app
      require_extensions(:app) do |name, path|
        begin
          ::App.run(name, "#{path}/routes".constantize)
        rescue NameError
        end
        begin
          Roda::RodaPlugins.register_plugin(name, path.constantize)
        rescue NameError
        end
      end
    end

    # Extend relay service with relay components provided by all active plugins
    def extend_relay
      return if extensions.key? :relay
      require_extensions(:relay)
    end

    # Extend schedule service with schedule components provided by all active
    # plugins
    def extend_schedule
      return if extensions.key? :schedule
      require_extensions(:schedule) do |name, path|
        path.constantize.new
      end
    end

    private

    # Require (and log) the service extensions provided by all active plugins
    #
    # @param service [Symbol] any of {Rodbot::SERVICES}
    # @yield additional code to execute after require
    # @return [self]
    def require_extensions(service)
      Rodbot.config(:plugin).each_key do |name|
        path = "rodbot/plugins/#{name}/#{service}"
        if rescued_require(path)
          Rodbot.log("#{path} required", level: Logger::DEBUG)
          extensions[service] ||= {}
          extensions[service][name] = path
          yield(name, path) if block_given?
        end
      end
      self
    end

    # Same as +require+ but never fail with +LoadError+
    #
    # @param path [String] path to require
    # @return [Boolean] true if required (again) or false if load failed
    def rescued_require(path)
      require path
      true
    rescue LoadError
      false
    end

  end
end
