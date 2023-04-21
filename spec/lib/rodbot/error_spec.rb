require_relative '../../spec_helper'

describe Rodbot::Error do
  subject do
    Rodbot::Error
  end

  describe :detailed_message do
    it "includes the details in detailed_message" do
      _(subject.new('message', 'details').detailed_message).must_equal 'message: details'
    end

    it "works without details" do
      _(subject.new('message').detailed_message).must_equal 'message'
    end
  end
end
