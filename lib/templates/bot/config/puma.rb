require_relative 'environment'

root = Dir.getwd

bind "tcp://127.0.0.1:9292"
pidfile "#{root}/tmp/puma.pid"
state_path "#{root}/tmp/puma.state"

custom_logger Environment.logger

threads 2, 4
