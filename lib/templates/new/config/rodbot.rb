name 'Rodbot'
timezone 'Etc/UTC'

plugin :matrix do
  room_id Rodbot.credentials.matrix.room_id
  access_token Rodbot.credentials.matrix.access_token
end

plugin :hal

plugin :word_of_the_day do
  time '10:00'
end
