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
      it "requires the corresponding app.rb file, registers routes and plugins" do
        $checkpoints = []
        App.stub(:run,
          -> { $checkpoints << :added if _1 == :hal && _2 == Rodbot::Plugins::Hal::App::Routes }
        ) do
          Roda::RodaPlugins.stub(:register_plugin,
            -> { $checkpoints << :registered if _1 == :hal && _2 == Rodbot::Plugins::Hal::App }
          ) do
            subject.extend_app
          end
        end
        _(subject.extensions[:app]).must_equal(
          hal: 'rodbot/plugins/hal/app',
          otp: 'rodbot/plugins/otp/app'
        )
        _($checkpoints).must_equal %i(added registered)
      end
    end

    describe :extend_relay do
      substitute '@config', on: Rodbot do
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
