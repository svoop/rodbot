# frozen_string_literal: true

require_relative 'adapters/base'
require_relative 'adapters/merriam_webster'
require_relative 'adapters/transparent'

module Rodbot
  class Plugins
    class WordOfTheDay
      class Adapter
        extend Forwardable

        def_delegator :@adapter, :message, :message

        def initialize(language)
          @language = language
          @adapter = (language == 'English' ? MerriamWebster : Transparent).new(language)
        end
      end
    end
  end
end
