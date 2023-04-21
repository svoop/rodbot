require_relative '../../spec_helper'

describe Rodbot::Relay do
  subject do
    Rodbot::Relay
  end

  describe :bind do
    it "returns 0.0.0.0 and port 10001 if RODBOT_SPLIT" do
      with "ENV['RODBOT_SPLIT']", 'true' do
        _(subject.bind_for(:matrix)).must_equal ['0.0.0.0', 10001]
      end
    end

    it "returns localhost and port derived from name if not RODBOT_SPLIT" do
      with "ENV['RODBOT_SPLIT']", 'false' do
        _(subject.bind_for(:matrix)).must_equal ['localhost', 16886]
      end
    end
  end

  describe :say do
    it "write the message to all relay extensions" do
      skip   # TODO: not implemented yet
    end
  end
end
