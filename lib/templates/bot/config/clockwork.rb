require_relative 'environment'

require 'clockwork'
require 'active_support/time'

# Define the jobs in `schedule.rb`.
module Clockwork
  configure do |config|
    config[:logger] = Environment.logger
  end

  handler do |proc|
    Environment.async(proc)
  end

  load Environment.root.join('config', 'schedule.rb')
end
