require_relative '../../spec_helper'

module Minitest
  module HTTPX
    @matched = true

    class << self
      def with(timeout:)
        @matched &&= timeout[:request_timeout] == 10
        self
      end

      def get(url, params:)
        @matched &&= url == 'http://localhost:7200/search' && params == { foo: 'bar' }
        self
      end

      def matched?
        @matched
      end
    end
  end
end

describe Rodbot::Rack do
  describe :request do
    substitute '::HTTPX', Minitest::HTTPX

    it "does a GET request to the full URL using HTTPX" do
      _(Rodbot.request('/search', params: { foo: 'bar' })).must_be :matched?
    end
  end
end
