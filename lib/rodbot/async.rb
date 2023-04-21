# frozen-string-literal: true

module Rodbot
  module Async
    extend self

    SuckerPunch.logger = Rodbot::Log.logger('async')

    # Perform code asynchronously
    #
    # In order not to interfere with tests, the code is performed synchronously
    # in case the current env is "test"!
    #
    # @example with block
    #   Environment.async do
    #     some_heavy_number_crunching
    #   end
    #
    # @example with proc
    #   Environment.async(-> { some_heavy_number_crunching })
    #
    # @param proc [Proc] either pass a proc to perform...
    # @yield ...or yield the code to perform (ignored if a proc is given)
    def perform(&block)
      if Rodbot.env.test?
        block.call
      else
        Job.perform_async(block)
      end
    end

    class Job
      include SuckerPunch::Job

      # Generic job which simply calls a proc
      #
      # @param proc [Proc] proc to call
      def perform(proc)
        proc.call
      end
    end
  end
end
