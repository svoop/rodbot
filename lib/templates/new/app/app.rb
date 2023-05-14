class App < Roda
  plugin :multi_run
  plugin :environments
  plugin :heartbeat
  plugin :public
  plugin :run_append_slash
  plugin :halt
  plugin :unescape_path
  plugin :render, layout: './layout', views: 'app/views'

  plugin :rodbot_arguments   # provides r.arguments shortcut for r.params["arguments"]

  run :help, Routes::Help

  route do |r|
    r.multi_run
    r.public
    r.root { view :root }
  end
end