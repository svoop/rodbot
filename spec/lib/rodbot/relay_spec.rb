require_relative '../../spec_helper'

describe Rodbot::Relay do
  subject do
    Rodbot::Relay
  end

  after do
    subject.instance_variable_set(:@bind, nil)
  end

  describe :bind do
    it "returns localhost and ports above 7200 by default" do
      with '@config', Rodbot::Config.new("plugin :matrix\nplugin :slack"), on: Rodbot do
        _(subject.bind_for(:matrix)).must_equal ['localhost', 7201]
        _(subject.bind_for(:slack)).must_equal ['localhost', 7202]
      end
    end

    it "returns localhost and ports about explicit port config" do
      with '@config', Rodbot::Config.new("plugin :matrix\nplugin :slack\nport 8888"), on: Rodbot do
        _(subject.bind_for(:matrix)).must_equal ['localhost', 8889]
        _(subject.bind_for(:slack)).must_equal ['localhost', 8890]
      end
    end

    it "returns value of RODBOT_RELAY_HOST and ports above 7200" do
      with "ENV['RODBOT_RELAY_HOST']", '0.0.0.0' do
        with '@config', Rodbot::Config.new("plugin :matrix\nplugin :slack"), on: Rodbot do
          _(subject.bind_for(:matrix)).must_equal ['0.0.0.0', 7201]
          _(subject.bind_for(:slack)).must_equal ['0.0.0.0', 7202]
        end
      end
    end
  end

  describe :say do
    it "write the message to all relay extensions" do
      skip   # TODO: not implemented yet
    end
  end
end
