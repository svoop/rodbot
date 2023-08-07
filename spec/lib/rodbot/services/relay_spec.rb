require_relative '../../../spec_helper'

describe Rodbot::Services::Relay do
  subject do
    Rodbot::Services::Relay
  end

  describe :url do
    after do
      subject.instance_variable_set(:@url, nil)
    end

    it "returns http://localhost and ports above 7200 by default" do
      with '@config', Rodbot::Config.new("plugin :matrix\nplugin :slack"), on: Rodbot do
        _(subject.url(:matrix)).must_equal 'http://localhost:7201'
        _(subject.url(:slack)).must_equal 'http://localhost:7202'
      end
    end

    it "returns localhost and ports about explicit port config" do
      with '@config', Rodbot::Config.new("plugin :matrix\nplugin :slack\nport 8888"), on: Rodbot do
        _(subject.url(:matrix)).must_equal 'http://localhost:8889'
        _(subject.url(:slack)).must_equal 'http://localhost:8890'
      end
    end

    it "returns value of RODBOT_RELAY_URL_XXX and ports above 7200" do
      with "ENV['RODBOT_RELAY_URL_MATRIX']", 'https://matrix.relay.local' do
        with '@config', Rodbot::Config.new("plugin :matrix\nplugin :slack"), on: Rodbot do
          _(subject.url(:matrix)).must_equal 'https://matrix.relay.local:7201'
          _(subject.url(:slack)).must_equal 'http://localhost:7202'
        end
      end
    end
  end
end
