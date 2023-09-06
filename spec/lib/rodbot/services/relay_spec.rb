require_relative '../../../spec_helper'

describe Rodbot::Services::Relay do
  subject do
    Rodbot::Services::Relay
  end

  describe :url do
    it "returns tcp://localhost and ports above 7200 by default" do
      Rodbot::Concerns::Memoize::suspend do
        with '@config', Rodbot::Config.new("plugin :matrix; plugin :slack"), on: Rodbot do
          _(subject.url(:matrix)).must_equal 'tcp://localhost:7201'
          _(subject.url(:slack)).must_equal 'tcp://localhost:7202'
        end
      end
    end

    it "returns tcp://localhost and ports above explicit port config" do
      Rodbot::Concerns::Memoize::suspend do
        with '@config', Rodbot::Config.new("plugin :matrix; plugin :slack; port 8888"), on: Rodbot do
          _(subject.url(:matrix)).must_equal 'tcp://localhost:8889'
          _(subject.url(:slack)).must_equal 'tcp://localhost:8890'
        end
      end
    end

    it "returns value of RODBOT_RELAY_URL_XXX and ports above 7200" do
      Rodbot::Concerns::Memoize::suspend do
        with "ENV['RODBOT_RELAY_URL_MATRIX']", 'tcp://matrix.relay.local' do
          with '@config', Rodbot::Config.new("plugin :matrix; plugin :slack"), on: Rodbot do
            _(subject.url(:matrix)).must_equal 'tcp://matrix.relay.local:7201'
            _(subject.url(:slack)).must_equal 'tcp://localhost:7202'
          end
        end
      end
    end
  end
end
