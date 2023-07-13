require_relative '../../spec_helper'

describe Rodbot::Relay do
  subject do
    Rodbot::Relay
  end

  describe :bind do
    it "returns 0.0.0.0 and port 10001 if RODBOT_SPLIT" do
      with "ENV['RODBOT_SPLIT']", 'true' do
        _(subject.bind_for(:matrix)).must_equal ['0.0.0.0', 7201]
      end
    end

    it "returns localhost and port derived from plugin name index if not RODBOT_SPLIT" do
      with "ENV['RODBOT_SPLIT']", 'false' do
        config = Rodbot::Config.new("plugin :matrix\nplugin :slack")
          with '@config', config, on: Rodbot do
          _(subject.bind_for(:matrix)).must_equal ['localhost', 7201]
          _(subject.bind_for(:slack)).must_equal ['localhost', 7202]
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
