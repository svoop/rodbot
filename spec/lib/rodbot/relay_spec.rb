# frozen_string_literal: true

require_relative '../../spec_helper'

module Rodbot
  class Relay
    class << self
      undef_method :write

      def write(message, extension)
        puts "#{extension}: `#{message}'"
      end
    end
  end
end

describe Rodbot::Relay do
  let :matrix do
    Rodbot::Relay.new.tap do |relay|
      relay.define_singleton_method(:name) { :matrix }
    end
   end

  let :slack  do
    Rodbot::Relay.new.tap do |relay|
      relay.define_singleton_method(:name) { :slack }
    end
  end

  describe :bind do
    it "returns localhost and ports above 7200 by default" do
      substitute '@config', Rodbot::Config.new("plugin :matrix; plugin :slack"), on: Rodbot do
        _(matrix.send(:bind)).must_equal ['localhost', 7201]
        _(slack.send(:bind)).must_equal ['localhost', 7202]
      end
    end

    it "returns localhost and ports about explicit port config" do
      substitute '@config', Rodbot::Config.new("plugin :matrix; plugin :slack; port 8888"), on: Rodbot do
        _(matrix.send(:bind)).must_equal ['localhost', 8889]
        _(slack.send(:bind)).must_equal ['localhost', 8890]
      end
    end

    it "returns value of RODBOT_RELAY_HOST and ports above 7200" do
      substitute "ENV['RODBOT_RELAY_HOST']", '0.0.0.0' do
        substitute '@config', Rodbot::Config.new("plugin :matrix; plugin :slack"), on: Rodbot do
          _(matrix.send(:bind)).must_equal ['0.0.0.0', 7201]
          _(slack.send(:bind)).must_equal ['0.0.0.0', 7202]
        end
      end
    end
  end

  describe :say do
    context "all relay extensions have say enabled" do
      substitute '@config', on: Rodbot do
        Rodbot::Config.new("plugin(:matrix) { say true }; plugin(:slack) { say true }")
      end

      it "writes the message to all relay extensions" do
        message = Rodbot::Message.new('foobar')
        _{ Rodbot.say(message.text) }.must_output "matrix: `#{message.dump}'\nslack: `#{message.dump}'\n"
      end

      it "writes the message to the explicitly given extension" do
        message = Rodbot::Message.new('foobar')
        _{ Rodbot.say(message.text, on: :slack) }.must_output "slack: `#{message.dump}'\n"
      end
    end

    context "some relay extensions have say enabled" do
      substitute '@config', on: Rodbot do
        Rodbot::Config.new("plugin(:matrix) { say true }; plugin(:slack)")
      end

      it "writes the message to all with say enabled" do
        message = Rodbot::Message.new('foobar')
        _{ Rodbot.say(message.text) }.must_output "matrix: `#{message.dump}'\n"
      end

      it "writes the message to the given with say enabled" do
        message = Rodbot::Message.new('foobar')
        _{ Rodbot.say(message.text, on: :matrix) }.must_output "matrix: `#{message.dump}'\n"
      end

      it "writes no message to the given with say disabled" do
        _{ Rodbot.say('foobar', on: :slack) }.must_be_silent
      end
    end

    context "no relay extensions have say enabled" do
      substitute '@config', on: Rodbot do
        Rodbot::Config.new("plugin(:matrix); plugin(:slack)")
      end

      it "writes no message to any relay extension" do
        _{ Rodbot.say('foobar') }.must_be_silent
      end
    end
  end
end
