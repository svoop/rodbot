# frozen-string-literal: true

module Rodbot
  class Error < StandardError
    def initialize(message, details=nil)
      @details = details
      super(message)
    end

    def detailed_message
      [message, @details].compact.join(': ')
    end
  end

  GeneratorError = Class.new(Error)
  PluginError = Class.new(Error)
  ServiceError = Class.new(Error)
  RelayError = Class.new(Error)
end
