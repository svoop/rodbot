loader = Zeitwerk::Loader.new
loader.logger = Rodbot::Log.logger('loader')
loader.push_dir(Rodbot.env.root.join('lib'))
loader.push_dir(Rodbot.env.root.join('app'))

if Rodbot.env.development? || Rodbot.env.test?
  loader.enable_reloading
  loader.setup
  run ->(env) do
    loader.reload
    Rodbot.plugins.extend_app
    App.call(env)
  end
else
  loader.setup
  Zeitwerk::Loader.eager_load_all
  Rodbot.plugins.extend_app
  run App.freeze.app
end
