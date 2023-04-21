# frozen-string-literal: true

using Rodbot::Refinements

module Rodbot

  # Foundation to run app, relay and schedule services
  class Services
    extend Forwardable

    def_delegator :@dispatcher, :run, :run
    def_delegator :@dispatcher, :interrupt, :interrupt

    def initialize
      @dispatcher = Rodbot::Dispatcher.new('rodbot')
    end

    def exist?(service)
      Rodbot::SERVICES.include? service.to_sym
    end

    def register(service, extension: nil)
      fail(Rodbot::ServiceError, "unknown service #{service}") unless exist? service
      tasks = "rodbot/services/#{service}".constantize.new.tasks(only: extension)
      tasks.each_with_index do |task, index|
        name = [service, (index if tasks.count > 1)].compact.join('-')
        @dispatcher.register(name, &task)
      end
    end
  end

end
