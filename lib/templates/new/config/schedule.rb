# Regular jobs performed asynchronously at a given time
module Clockwork
  every(10.seconds, -> { nil })
end
