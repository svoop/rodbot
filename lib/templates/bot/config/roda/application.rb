class Application < Roda
  # TODO: make sure any other container IP can connect without hardcoding it
  LOCAL = %r(
    127\.0\.0\.1 |
    ::1 |
    172\.16\.42\.\d+
  )x.freeze

  plugin :environments
  plugin :heartbeat
  plugin :halt
  plugin :unescape_path
  plugin :public
  plugin :empty_root
  plugin :hash_branch_view_subdir
  plugin :render, engine: 'slim', layout: './layout'

  plugin :gitlab_webhook
  plugin :github_webhook
  plugin :hal

  include Bot

  route do |r|
    r.public
    r.hash_branches
    r.gitlab_webhook
    r.github_webhook
    r.hal
  end

  private

  def local?
    LOCAL.match? request.ip
  end
end
