require_relative '../../spec_helper'

require 'roda'

module Minitest::Refinements
  refine App.singleton_class do
    def run(*)
    end
  end
end
using Minitest::Refinements

describe Rodbot::Plugins do
  subject do
    Rodbot::Plugins.new
  end

  describe :extensions do
    describe :extend_app do
      it "requires the corresponding app.rb file" do
        subject.extend_app
        _(subject.extensions[:app]).must_equal(
          hal: 'rodbot/plugins/hal/app',
          otp: 'rodbot/plugins/otp/app'
        )
      end

      it "registers App routes" do
        subject.instance_variable_set(:@extensions, {})
        App.stub(:run,
          -> { throw :added if _1 == :hal && _2 == Rodbot::Plugins::Hal::App::Routes }
        ) do
          _{ subject.extend_app }.must_throw :added
        end
      end

      it "registers Roda plugins" do
        subject.instance_variable_set(:@extensions, {})
        Roda::RodaPlugins.stub(:register_plugin,
          -> { throw :registered if _1 == :hal && _2 == Rodbot::Plugins::Hal::App }
        ) do
          _{ subject.extend_app }.must_throw :registered
        end
      end
    end

    describe :extend_relay do
      with '@config', on: Rodbot do
        Rodbot::Config.new('plugin :matrix')
      end

      it "requires the corresponding relay.rb file" do
        subject.extend_relay
        _(subject.extensions[:relay]).must_equal(matrix: 'rodbot/plugins/matrix/relay')
      end
    end

    describe :extend_schedule do
      it "requires the corresponding schedule.rb file" do
        subject.extend_schedule rescue nil
        _(subject.extensions[:schedule]).must_equal(word_of_the_day: 'rodbot/plugins/word_of_the_day/schedule')
      end
    end
  end

  describe :rescued_require do
    it "returns true if the file is found and (already) required" do
      2.times do
        _(subject.send(:rescued_require, 'rodbot/plugins/matrix/relay')).must_equal true
      end
    end

    it "returns false if the file is not found" do
      _(subject.send(:rescued_require, 'rodbot/does_not_exist')).must_equal false
    end
  end
end
