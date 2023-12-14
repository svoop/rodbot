# frozen_string_literal: true

module WordOfTheDay
  class Adapter
    class Transparent < Base
      LANGUAGE_CODES = {
        'arabic' => 'ar',
        'chinese' => 'zh',
        'dutch' => 'nl',
        'esperanto' => 'esp',
        'french' => 'fr',
        'german' => 'de',
        'irish' => 'ga',
        'italian' => 'it',
        'japanese' => 'ja',
        'latin' => 'la',
        'polish' => 'pl',
        'portuguese' => 'pt',
        'russian' => 'ru',
        'spanish' => 'es'
      }.freeze

      def word
        xml.match(/<word>(.+?)</)&.captures&.first
      end

      def url
        "https://wotd.transparent.com/widget/?lang=#{language}&date=#{today}"
      end

      private

      def today
        Time.now.strftime('%m-%d-%Y')
      end

      def language_code
        LANGUAGE_CODES.fetch(language, language)
      end

      def xml
        xml_url = "https://wotd.transparent.com/rss/#{today}-#{language_code}-widget.xml"
        case (response = HTTPX.get(xml_url))
          in { status: 200 } then response.body.to_s
          else ''
        end
      end
    end
  end
end
