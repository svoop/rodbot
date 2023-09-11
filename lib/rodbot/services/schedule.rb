# frozen-string-literal: true

require 'clockwork'
require 'active_support/time'

module Rodbot
  class Services
    class Schedule

      def tasks(**)
        puts "Starting schedule service"
        [method(:run)]
      end

      private

      def run
        Clockwork.instance_eval do
          configure { _1[:logger] = Rodbot::Log.logger('schedule') }
          handler { Rodbot::Async.perform(&_1) }
        end
        Rodbot.plugins.extend_schedule
        require Rodbot.env.root.join('config', 'schedule')
        Clockwork.run
      end

    end
  end
end
