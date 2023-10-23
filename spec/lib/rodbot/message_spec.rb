require_relative '../../spec_helper'

describe Rodbot::Message do
  subject do
    Rodbot::Message.new('foo', room: 'bar')
  end

  describe :initialize do
    context "with raw message text" do
      it "fails without arguments" do
        _{ Rodbot::Message.new }.must_raise ArgumentError
      end

      it "treats string as raw message if no prelude is present" do
        _(Rodbot::Message.new('foo').to_h).must_equal({ class: 'Rodbot::Message', text: 'foo', room: nil })
      end

      it "accepts an optional room argument" do
        _(Rodbot::Message.new('foo', room: 'bar').to_h).must_equal({ class: 'Rodbot::Message', text: 'foo', room: 'bar' })
      end
    end

    context "with valid dumped message object" do
      it "recreates the dumped message object" do
        _(Rodbot::Message.new(subject.dump)).must_equal subject
      end

      it "overwrites room if optional room argument is present" do
        _(Rodbot::Message.new(subject.dump, room: 'biz').to_h).must_equal({ class: 'Rodbot::Message', text: 'foo', room: 'biz' })
      end
    end

    context "with invalid dumped message object" do
      it "fails on invalid Base64" do
        base64 = Rodbot::Message::PRELUDE + '&&&'
        _{ Rodbot::Message.new(base64) }.must_raise ArgumentError
      end

      it "fails on invalid JSON" do
        base64 = Rodbot::Message::PRELUDE + Base64.strict_encode64('invalid')
        _{ Rodbot::Message.new(base64)}.must_raise ArgumentError
      end

      it "fails unless registered class is Rodbot::Message" do
        json = { class: 'invalid', text: 'text', room: 'room' }.to_json
        base64 = Rodbot::Message::PRELUDE + Base64.strict_encode64(json)
        _{ Rodbot::Message.new(base64) }.must_raise ArgumentError
      end
    end
  end

  describe :to_h do
    it "returns the message as Hash" do
      _(subject.to_h).must_equal({ class: 'Rodbot::Message', text: 'foo', room: 'bar' })
    end
  end

  describe :== do
    it "returns true for identical messages" do
      _(subject == subject).must_equal true
    end

    it "returns false for different messages" do
      _(subject == Rodbot::Message.new('notfoo')).must_equal false
    end
  end

  describe :dump do
    it "encodes the message with strict Base64 and prefixes the PRELUDE" do
      _(subject.dump).must_match(/\A#{Rodbot::Message::PRELUDE}[A-Za-z0-9\/+=]+\z/)
    end
  end
end
