# frozen-string-literal: true

require 'httpx'

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
      # @param params [Hash] params hash e.g. +{ search: 'foobar' }+
      # @param timeout [Integer] max seconds to wait for response
      # @return [HTTPX::Response]
      def request(path, params: {}, timeout: 10)
        HTTPX.with(timeout: { request_timeout: timeout }).get(Rodbot::Services::App.url.uri_concat(path), params: params)
      end

    end

  end
end
