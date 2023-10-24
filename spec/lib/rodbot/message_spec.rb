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

      it "treats string as raw message unless deserializable" do
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
  end

  describe :dump do
    it "encodes the message" do
      _(subject.dump).must_match(/\A#{Rodbot::Serializer::PRELUDE}[A-Za-z0-9\/+=]+\z/)
    end

    it "performs successful roundtrips" do
      _(Rodbot::Message.new(subject.dump).to_h).must_equal({ class: 'Rodbot::Message', text: 'foo', room: 'bar' })
      _(Rodbot::Message.new(Rodbot::Message.new('foobar').dump).to_h).must_equal({ class: 'Rodbot::Message', text: 'foobar', room: nil })
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
end
