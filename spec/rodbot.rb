name 'Rodbot'
timezone 'Etc/UTC'

plugin :hal

plugin :word_of_the_day do
  time '10:00'
end

plugin :otp do
  secret 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
  drift 3
end
