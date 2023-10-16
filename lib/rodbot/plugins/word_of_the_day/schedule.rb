# frozen_string_literal: true

require 'httpx'

module Rodbot
  class Plugins
    class WordOfTheDay
      class Schedule
        def initialize
          Clockwork.every(1.day, -> { Rodbot.say message }, at: time)
        end

        private

        def time
          Rodbot.config(:plugin, :word_of_the_day, :time) || '12:00'
        end

        def message
          Rodbot::Plugins::WordOfTheDay::Today.new.message
        end

      end

      class Today
        def initialize
          @response = HTTPX.with(timeout: { request_timeout: 60 }).get('https://www.merriam-webster.com/word-of-the-day')
        end

        def message
          if @response.status == 200
            "Word of the day: [#{word}](#{url})"
          else
            "Sorry, there was a problem fetching the word of the day."
          end
        end

        private

        def word
          @response.body.to_s.match(/<h2 class="word-header-txt">(.+?)</).captures.first
        end

        def url
          @response.body.to_s.match(/<meta property="og:url" content="(.+?)"/).captures.first
        end
      end

    end
  end
end
