require 'roda'

loader = Rodbot.env.loader
loader.on_load('Application') do
  Dir[Environment.root.join('routes', '*.rb')].each { load _1 }
end

if Rodbot.env.development? || Rodbot.env.test?
  loader.enable_reloading
  loader.setup
  run ->(env) do
    loader.reload
    Application.call(env)
  end
else
  loader.setup
  Zeitwerk::Loader.eager_load_all
  run Application.freeze.app
end
