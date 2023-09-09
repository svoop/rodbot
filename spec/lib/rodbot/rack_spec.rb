require_relative '../../spec_helper'

module Minitest
  module HTTParty
    def self.get(url, query:, timeout:)
      url == 'http://localhost:7200/search' && query == { foo: 'bar' } && timeout == 10
    end
  end
end

describe Rodbot::Rack do
  describe :request do
    with '::HTTParty', Minitest::HTTParty

    it "does a GET request to the full URL using HTTParty" do
      _(Rodbot.request('/search', query: { foo: 'bar' })).must_equal true
    end
  end
end
