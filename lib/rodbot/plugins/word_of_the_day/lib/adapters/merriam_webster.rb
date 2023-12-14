# frozen_string_literal: true

module WordOfTheDay
  class Adapter
    class MerriamWebster < Base
      private

      def word
        html.match(/<h2 class="word-header-txt">(.+?)</)&.captures&.first
      end

      def url
        "https://www.merriam-webster.com/word-of-the-day/#{today}"
      end

      private

      def today
        Time.now.strftime('%F')
      end

      def html
        case (response = HTTPX.get(url))
          in { status: 200 } then response.body.to_s
          else ''
        end
      end
    end
  end
end
