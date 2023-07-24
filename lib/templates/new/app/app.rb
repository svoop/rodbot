class App < Roda
  plugin :rodbot

  route do |r|
    r.multi_run
    r.public
    r.root { view :root }
  end

  run :help, Routes::Help
end
