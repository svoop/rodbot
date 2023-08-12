require_relative '../../spec_helper'

module Rodbot
  class Relay
    def self.write(message, extension)
      puts "#{extension}: `#{message}'"
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
      with '@config', Rodbot::Config.new("plugin :matrix\nplugin :slack"), on: Rodbot do
        _(matrix.send(:bind)).must_equal ['localhost', 7201]
        _(slack.send(:bind)).must_equal ['localhost', 7202]
      end
    end

    it "returns localhost and ports about explicit port config" do
      with '@config', Rodbot::Config.new("plugin :matrix\nplugin :slack\nport 8888"), on: Rodbot do
        _(matrix.send(:bind)).must_equal ['localhost', 8889]
        _(slack.send(:bind)).must_equal ['localhost', 8890]
      end
    end

    it "returns value of RODBOT_RELAY_HOST and ports above 7200" do
      with "ENV['RODBOT_RELAY_HOST']", '0.0.0.0' do
        with '@config', Rodbot::Config.new("plugin :matrix\nplugin :slack"), on: Rodbot do
          _(matrix.send(:bind)).must_equal ['0.0.0.0', 7201]
          _(slack.send(:bind)).must_equal ['0.0.0.0', 7202]
        end
      end
    end
  end

  describe :say do
    context "all relay extensions have say enabled" do
      let :config do
        "plugin(:matrix) { say true }\nplugin(:slack) { say true }"
      end

      it "writes the message to all relay extensions" do
        with '@config', Rodbot::Config.new(config), on: Rodbot do
          _{ Rodbot.say('foobar') }.must_output "matrix: `foobar'\nslack: `foobar'\n"
        end
      end

      it "writes the message to the explicitly given extension" do
        with '@config', Rodbot::Config.new(config), on: Rodbot do
          _{ Rodbot.say('foobar', on: :slack) }.must_output "slack: `foobar'\n"
        end
      end
    end

    context "some relay extensions have say enabled" do
      let :config do
        "plugin(:matrix) { say true }\nplugin(:slack)"
      end

      it "writes the message to all with say enabled" do
        with '@config', Rodbot::Config.new(config), on: Rodbot do
          _{ Rodbot.say('foobar') }.must_output "matrix: `foobar'\n"
        end
      end

      it "writes the message to the given with say enabled" do
        with '@config', Rodbot::Config.new(config), on: Rodbot do
          _{ Rodbot.say('foobar', on: :matrix) }.must_output "matrix: `foobar'\n"
        end
      end

      it "writes no message to the given with say disabled" do
        with '@config', Rodbot::Config.new(config), on: Rodbot do
          _{ Rodbot.say('foobar', on: :slack) }.must_be_silent
        end
      end
    end

    context "no relay extensions have say enabled" do
      let :config do
        "plugin(:matrix)\nplugin(:slack)"
      end

      it "writes no message to any relay extension" do
        with '@config', Rodbot::Config.new(config), on: Rodbot do
          _{ Rodbot.say('foobar') }.must_be_silent
        end
      end
    end
  end
end
