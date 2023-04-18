require_relative 'config/environment'

require 'roda'

loader = Environment.loader
loader.push_dir(Environment.root.join('config', 'roda'))
loader.on_load('Application') do
  Dir[Environment.root.join('routes', '*.rb')].each { load _1 }
end

if Environment.development?
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
