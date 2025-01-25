# frozen_string_literal: true

require 'uri'
require 'kramdown'

module Rodbot
  module Refinements

    # @!method camelize
    #   Convert from under_scores to CamelCase
    #
    #   @example
    #     camelize('foo_bar')   # => 'FooBar'
    #
    #   @return [String] CamelCased string
    refine String do
      def camelize
        Rodbot::Refinements.inflector.camelize(self, nil)
      end
    end

    # @!method constantize
    #   Convert module or class path to module or class
    #
    #   @example
    #     'foo/bar_baz'.constantize   # => Foo::BarBaz
    #
    #   @return [Class, Module] class or module
    refine String do
      def constantize
        Module.const_get(self.split('/').map(&:camelize).join('::'))
      end
    end

    # @!method uri_concat
    #   Safely concat path segments to a URI string
    #
    #   {URI#join} is ultimately used to add the given segments which has a
    #   maybe counter-intuitive API at first. Check out the docs of {URI#join}
    #   and the examples below.
    #
    #   @example
    #     s = 'http://example.com'
    #     s.uri_concat('foo')               # => "http://example.com/foo"
    #     s.uri_concat('foo/')              # => "http://example.com/foo/"
    #     s.uri_concat('foo', 'bar')        # => "http://example.com/bar"   <- sic!
    #     s.uri_concat('foo/, 'bar')        # => "http://example.com/foo/bar"
    #     s.uri_concat('foo/, 'bar.html')   # => "http://example.com/foo/bar.html"
    #     s.uri_concat('föö')               # => "http://example.com/f%C3%B6%C3%B6"
    #
    #   @param segments [Array<String>] path segments
    #   @return [String] concatted URI
    refine String do
      def uri_concat(*segments)
        parser = URI::RFC2396_PARSER
        segments.inject(URI(self)) do |uri, segment|
          uri + parser.escape(segment)
        end.to_s
      end
    end

    # @!method md_to_html
    #   Converts Markdown in the string to HTML
    #
    #   @example
    #     '**important**'.md_to_html   # => '<strong>important</strong>'
    #
    #   @return [String] HTML
    refine String do
      def md_to_html
        Kramdown::Document.new(self, input: 'GFM').to_html.strip
      end
    end

    # @!method html_to_text
    #   Converts HTML to plain text by removing all tags
    #
    #   @example
    #     '<strong>important</strong>'.html_to_text   # => 'important'
    #
    #   @return [String] text
    refine String do
      def html_to_text
        self.gsub(/<.*?>/, '')
      end
    end

    # @!method psub
    #   Replace placeholders
    #
    #   Placeholders are all UPCASE and wrapped in [[ and ]]. They must match
    #   keys in the placeholder hash, however, these keys are Symbols and all
    #   downcase.
    #
    #   @example
    #     placeholders = { sender: 'Oggy' }
    #     'Hi, [[SENDER]]!'.psub(placeholders)   # => 'Hi, Oggy!'
    #
    #   @return [String] string without placeholders
    refine String do
      def psub(placeholders)
        self.gsub(/\[\[.*?\]\]/) { placeholders[_1[2..-3].downcase.to_sym] }
      end
    end

    class << self
      include Rodbot::Memoize

      # Reusable inflector instance
      #
      # @return [Zeitwerk::Inflector]
      memoize def inflector
        Zeitwerk::Inflector.new
      end
    end

  end
end
