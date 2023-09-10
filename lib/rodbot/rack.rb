# frozen-string-literal: true

require 'httparty'

using Rodbot::Refinements

module Rodbot
  module Rack

    class << self

      # Default +config.ru+
      #
      # In case you wish to do things differently, just copy the contents of
      # this method into your +config.ru+ file and tweak it.
      def boot(rack)
        loader = Zeitwerk::Loader.new
        loader.logger = Rodbot::Log.logger('loader')
        loader.push_dir(Rodbot.env.root.join('lib'))
        loader.push_dir(Rodbot.env.root.join('app'))

        if Rodbot.env.development? || Rodbot.env.test?
          loader.enable_reloading
          loader.setup
          rack.run ->(env) do
            loader.reload
            App.call(env)
          end
        else
          loader.setup
          Zeitwerk::Loader.eager_load_all
          rack.run App.freeze.app
        end
      end

      # Send request to the app service
      #
      # @param path [String] path e.g. +/help+
      # @param query [Hash] query hash e.g. +{ search: 'foobar' }+
      # @param method [Symbol, String] HTTP method
      # @param timeout [Integer] max seconds to wait for response
      # @return [HTTParty::Response]
      def request(path, query: {}, method: :get, timeout: 10)
        HTTParty.send(method, Rodbot::Services::App.url.uri_concat(path), query: query, timeout: timeout)
      end

    end

  end
end
