module Rodbot
  module CLI
    module Commands
      extend Dry::CLI::Registry

      register 'credentials', Credentials, aliases: %w(cred)
      register 'new', New
      register 'simulator', Simulator, aliases: %w(sim)
      register 'start', Start, aliases: %w(s)
      register 'version', Version, aliases: %w(v -v --version)
    end
  end
end
