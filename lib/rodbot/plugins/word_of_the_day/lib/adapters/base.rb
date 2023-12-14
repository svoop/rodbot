# frozen_string_literal: true

require 'httpx'

module WordOfTheDay
  class Adapter
    class Base
      attr_reader :language

      def initialize(language)
        @language = language.downcase
      end

      def message
        if word
          "[#{word}](#{url}) (#{language.capitalize})"
        else
          "~~#{language.capitalize}~~"
        end
      end
    end
  end
end
