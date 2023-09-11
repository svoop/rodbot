# Regular jobs performed asynchronously at a given time
module Clockwork
  # every 1.hour, -> { Rodbot.say 'Ping!' }
  # every 1.day, -> { Rodbot.say 'Time for a cup of tea!' }, at: '16:00'
end
