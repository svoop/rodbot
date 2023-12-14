# frozen_string_literal: true

require 'httpx'

require_relative 'lib/adapter'

module Rodbot
  class Plugins
    class WordOfTheDay
      class Schedule
        def initialize
          Clockwork.every(1.day, -> { Rodbot.say "Word of the day: #{message}" }, at: time)
        end

        private

        def time
          Rodbot.config(:plugin, :word_of_the_day, :time) || '12:00'
        end

        def languages
          Rodbot.config(:plugin, :word_of_the_day, :languages) || %w(english)
        end

        def message
          languages.map { ::WordOfTheDay::Adapter.new(_1).message }.compact.join(' / ')
        end
      end
    end
  end
end

