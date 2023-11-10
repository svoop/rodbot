require 'rotp'

name 'Rodbot'
time_zone 'Etc/UTC'

plugin :hal

plugin :word_of_the_day do
  time '10:00'
end

plugin :otp do
  secret ROTP::Base32.random
  drift 3
end
