# frozen-string-literal: true

module Rodbot
  module Rack

    # Default +config.ru+
    #
    # In case you wish to do things differently, just copy the contents of
    # this method into your +config.ru+ file and tweak it.
    def self.boot(rack)
      loader = Zeitwerk::Loader.new
      loader.logger = Rodbot::Log.logger('loader')
      loader.push_dir(Rodbot.env.root.join('lib'))
      loader.push_dir(Rodbot.env.root.join('app'))

      if Rodbot.env.development? || Rodbot.env.test?
        loader.enable_reloading
        loader.setup
        rack.run ->(env) do
          loader.reload
# TODO: obsolete?
#          Rodbot.plugins.extend_app
          App.call(env)
        end
      else
        loader.setup
        Zeitwerk::Loader.eager_load_all
# TODO: obsolete?
#        Rodbot.plugins.extend_app
        rack.run App.freeze.app
      end
    end

  end
end
