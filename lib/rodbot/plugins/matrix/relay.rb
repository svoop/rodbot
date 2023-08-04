# frozen_string_literal: true

require 'matrix_sdk'

using Rodbot::Refinements

module Rodbot
  class Plugins
    class Matrix
      class Relay < Rodbot::Relay

        def loops
          client.on_invite_event.add_handler { on_invite(_1) }
          client.sync(filter: filter(empty: true))
          client.on_event.add_handler('m.room.message') { on_message(_1) }
          [method(:read_loop), method(:write_loop)]
        end

        private

        def access_token
          Rodbot.config(:plugin, :matrix, :access_token)
        rescue => error
          raise Rodbot::PluginError.new("invalid access_token", error.message)
        end

        def room_id
          Rodbot.config(:plugin, :matrix, :room_id)
        rescue => error
          raise Rodbot::PluginError.new("invalid room_id", error.message)
        end

        def homeserver
          room_id.split(':').last
        rescue => error
          raise Rodbot::PluginError.new("invalid room_id", error.message)
        end

        def client
          @client ||= MatrixSdk::Client.new(homeserver, access_token: access_token, client_cache: :some)
        end

        def room
          @room ||= client.ensure_room(room_id)
        end

        def read_loop
          loop do
            client.sync(filter: filter)
          rescue StandardError
            sleep 5
          end
        end

        def write_loop
          server = TCPServer.new(*bind)
          loop do
            Thread.start(server.accept) do |remote|
              body = remote.gets("\x04")
              remote.close
              body.force_encoding('UTF-8')
              room.send_html body.md_to_html
            end
          end
        end

        def on_invite(invite)
          client.join_room(invite[:room_id]) if Rodbot.config(:plugin, :matrix, :room_id) == invite[:room_id]
        end

        def on_message(message)
          if message.content[:msgtype] == 'm.text' && message.content[:body].start_with?('!')
            html = 'pong' if message.content[:body] == '!ping'
            html ||= reply_to(message)
            room.send_html(html)
          end
        end

        def reply_to(message)
          sender = client.get_user(message.sender)
          command, argument = message.content[:body][1..].split(/\s+/, 2)
          body = begin
            response = HTTParty.get("#{@options[:backend]}/bot/#{command}", query: { argument: argument }, timeout: 10)
            case response.code
              when 200 then response.body
              when 404 then "[[SENDER]] I've never heard of `!#{command}`, try `!help` instead. 🤔"
              else fail
            end
          rescue
            "[[SENDER]] I'm having trouble talking to the backend. 💣"
          end
          body.md_to_html.psub(placeholders(sender))
        end

        def placeholders(sender)
          {
            sender: "[@#{sender.friendly_name}](https://matrix.to/#/#{sender.id})"
          }
        end

        def filter(empty: false)
          {
            presence: { types: [] },
            account_data: { types: [] },
            room: {
              ephemeral: { types: [] },
              state: {
                types: (empty ? [] : ['m.room.*']),
                lazy_load_members: true
              },
              timeline: {
                types: (empty ? [] : ['m.room.message'])
              },
              account_data: { types: [] }
            }
          }
        end

      end
    end
  end
end
