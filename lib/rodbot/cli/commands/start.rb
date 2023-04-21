# frozen-string-literal: true

module Rodbot
  class CLI
    module Commands
      class Start < Rodbot::CLI::Command
        desc 'Start Rodbot or parts of it'
        argument :service, values: Rodbot::SERVICES, desc: 'Which service to start or all by default'
        argument :extension, desc: 'Which service extension to start or all by default (only if SERVICE is relay)'
        option :daemonize, type: :boolean, desc: "Whether to daemonize processes, default: true (all services) or false (one service)"
        option :debugger, type: :boolean, default: false, desc: "Whether to load the debugger"

        def rescued_call(service: nil, extension: nil, daemonize: false, debugger: false, **)
          require 'debug' if debugger
          daemonize = true unless service
          Rodbot::Services.new.then do |services|
            (service ? [service] : Rodbot::SERVICES).each do |service|
              services.register(service, extension: extension)
            end
            services.run(daemonize: daemonize)
          end
        end
      end
    end
  end
end
