# frozen_string_literal: true

require_relative 'lib/rodbot/version'

Gem::Specification.new do |spec|
  spec.name        = 'rodbot'
  spec.version     = Rodbot::VERSION
  spec.summary     = 'Minimalistic framework to build chat bots on top of a Roda backend'
  spec.description = <<~END
    Just the bare minimum of what's needed to create bi-directional chat bots
    using Roda as backend, sucker_punch and Clockwork for async and timed jobs.
  END
  spec.authors     = ['Sven Schwyn']
  spec.email       = ['ruby@bitcetera.com']
  spec.homepage    = 'https://github.com/svoop/rodbot'
  spec.license     = 'MIT'

  spec.metadata = {
    'homepage_uri'      => spec.homepage,
    'changelog_uri'     => 'https://github.com/svoop/rodbot/blob/main/CHANGELOG.md',
    'source_code_uri'   => 'https://github.com/svoop/rodbot',
    'documentation_uri' => 'https://www.rubydoc.info/gems/rodbot',
    'bug_tracker_uri'   => 'https://github.com/svoop/rodbot/issues'
  }

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { _1.match? %r{^spec/} }
  end
  spec.require_paths = %w(lib)
  spec.bindir        = 'exe'
  spec.executables   = %w(rodbot)

  spec.extra_rdoc_files = Dir['README.md', 'CHANGELOG.md', 'LICENSE.txt']
  spec.rdoc_options    += [
    '--title', 'Rodbot',
    '--main', 'README.md',
    '--line-numbers',
    '--inline-source',
    '--quiet'
  ]

  spec.required_ruby_version = '>= 3.0.0'

  spec.add_runtime_dependency 'zeitwerk', '~> 2'
  spec.add_runtime_dependency 'ostruct'
  spec.add_runtime_dependency 'fiddle'
  spec.add_runtime_dependency 'logger'
  spec.add_runtime_dependency 'dry-cli', '~> 1', '<1.4.0'   # TODO: broken on 1.4 - see https://github.com/dry-rb/dry-cli/issues/126
  spec.add_runtime_dependency 'dry-credentials', '~> 0'
  spec.add_runtime_dependency 'tty-markdown', '~> 0'
  spec.add_runtime_dependency 'pastel', '~> 0'
  spec.add_runtime_dependency 'httpx', '~> 1'
  spec.add_runtime_dependency 'puma', '~> 6', '>= 6.2'
  spec.add_runtime_dependency 'roda', '~> 3'
  spec.add_runtime_dependency 'tilt', '~> 2'
  spec.add_runtime_dependency 'kramdown', '~> 2'
  spec.add_runtime_dependency 'kramdown-parser-gfm', '~> 1'
  spec.add_runtime_dependency 'clockwork', '~> 3'
  spec.add_runtime_dependency 'sucker_punch', '~> 3'
  spec.add_runtime_dependency 'debug'

  # Sync versions with lib/templates/new/gems.rb
  spec.add_development_dependency 'redis', '~> 5'
  spec.add_development_dependency 'rotp', '~> 6'
  spec.add_development_dependency 'matrix_sdk', '~> 2'
  spec.add_development_dependency 'slack-ruby-client', '~> 2'
  spec.add_development_dependency 'async-websocket', '~> 0.8.0'  # see https://github.com/slack-ruby/slack-ruby-client/blob/720b75fe7eda964e3da61bf442532baa66c2927c/lib/slack/real_time/concurrency/async.rb#L137

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-mock'
  spec.add_development_dependency 'minitest-flash'
  spec.add_development_dependency 'minitest-substitute'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-minitest'
  spec.add_development_dependency 'yard'
end
