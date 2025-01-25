# frozen_string_literal: true

module Rodbot
  class CLI
    module Commands
      extend Dry::CLI::Registry

      register 'credentials', Credentials, aliases: %w(cred)
      register 'deploy', Deploy
      register 'new', New
      register 'simulator', Simulator, aliases: %w(sim)
      register 'start', Start, aliases: %w(up)
      register 'stop', Stop, aliases: %w(down)
      register 'console', Console, aliases: %w(c)
      register 'version', Version, aliases: %w(-v --version)
    end
  end
end
