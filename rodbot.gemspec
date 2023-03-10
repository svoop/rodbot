# frozen_string_literal: true

require_relative 'lib/rodbot/version'

Gem::Specification.new do |spec|
  spec.name        = 'rodbot'
  spec.version     = Rodbot::VERSION
  spec.summary     = 'Minimalistic framework to build bots on top of a Roda backend'
  spec.description = <<~END
    Just the bare minimum of what's needed to create bi-directional chat bots
    using Roda as backend, sucker_punch and Clockwork for unpersisted async
    and timed jobs.
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

  spec.files         = Dir['lib/**/*']
  spec.require_paths = %w(lib)
  spec.bindir        = 'exe'
  spec.executables   = %w(rodbot)

  spec.cert_chain  = ["certs/svoop.pem"]
  spec.signing_key = File.expand_path(ENV['GEM_SIGNING_KEY']) if ENV['GEM_SIGNING_KEY']

  spec.extra_rdoc_files = Dir['README.md', 'CHANGELOG.md', 'LICENSE.txt']
  spec.rdoc_options    += [
    '--title', 'Rodbot',
    '--main', 'README.md',
    '--line-numbers',
    '--inline-source',
    '--quiet'
  ]

  spec.required_ruby_version = '>= 3.0.0'

  spec.add_runtime_dependency 'dry-cli', '~> 1'
  spec.add_runtime_dependency 'zeitwerk', '~> 2'
  spec.add_runtime_dependency 'roda', '~> 3'

  spec.add_development_dependency 'debug'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-sound'
  spec.add_development_dependency 'minitest-focus'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-minitest'
  spec.add_development_dependency 'yard'
end
