# frozen_string_literal: true

require 'slack-ruby-client'

using Rodbot::Refinements

module Rodbot
  class Plugins
    class Slack
      class Relay < Rodbot::Relay
        include Rodbot::Memoize

        def loops
          ::Slack.configure do |config|
            config.token = access_token
          end
          [method(:read_loop), method(:write_loop)]
        end

        private

        def access_token
          Rodbot.config(:plugin, :slack, :access_token)
        rescue => error
          raise Rodbot::PluginError.new("invalid access_token", error.message)
        end

        memoize def client
          ::Slack::RealTime::Client.new
        end

        def channel_id
          Rodbot.config(:plugin, :slack, :channel_id)
        rescue => error
          raise Rodbot::PluginError.new("invalid channel_id", error.message)
        end

        def write_loop
          server = TCPServer.new(*bind)
          loop do
            Thread.start(server.accept) do |remote|
              body = remote.gets("\x04")
              remote.close
              body.force_encoding('UTF-8')
              client.web_client.chat_postMessage(
                channel: channel_id,
                text: md_to_slack_text(body),
                as_user: true
              )
            end
          end
        end

        def read_loop
          client.on :message do |message|
            on_message(message) if message.channel == channel_id
          end
          client.start!
        end

        def on_message(message)
          if message.text.start_with?('!')
            client.web_client.chat_postMessage(
              channel: message.channel,
              text: reply_to(message),
              as_user: true
            )
          end
        end

        def reply_to(message)
          command(*message.text[1..].split(/\s+/, 2)).
            psub(placeholders(message.user)).
            then { md_to_slack_text(_1) }
        end

        # @see https://api.slack.com/reference/surfaces/formatting
        def placeholders(sender)
          {
            sender: "<@#{sender}>"
          }
        end

        # @see https://api.slack.com/reference/surfaces/formatting
        def md_to_slack_text(md)
          md.
            gsub(/\[(.+?)\]\((.+?)\)/, '<\2|\1>').   # convert links
            gsub(/^\s*[*-]\s+/, '• ')                # convert bullet lists
        end

      end
    end
  end
end
