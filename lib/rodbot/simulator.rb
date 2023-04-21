# frozen-string-literal: true

require 'readline'
require 'httparty'
require 'pastel'
require 'tty-markdown'

using Rodbot::Refinements

module Rodbot

  # Simulate a chat client
  class Simulator

    # App address
    APP_URL = 'http://localhost:10000'

    # @param sender [String] sender to mimick
    # @param raw [Boolean] whether to display raw Markdown
    def initialize(sender, raw: false)
      @sender, @raw = sender, raw
      @pastel = Pastel.new
    end

    def run
      puts nil, "Talking to app on #{APP_URL} as sender #{@pastel.inverse(@sender)}."
      puts 'Type commands beginning with "!" or empty line to exit.', nil
      while (line = Readline.readline("rodbot> ", true)) && !line.empty?
        puts nil, reply_to(line), nil
      end
      puts
    end

    private

    def reply_to(message)
      return "(no command given)" unless message.match?(/^!/)
      command, argument = message[1..].split(/\s+/, 2)
      body = begin
        response = HTTParty.get("#{APP_URL}/#{command}", query: { argument: argument }, timeout: 10)
        case response.code
          when 200 then response.body
          when 404 then "[[SENDER]] I've never heard of `!#{command}`, try `!help` instead. 🤔"
          else fail
        end
      rescue
        "[[SENDER]] I'm having trouble talking to the app. 💣"
      end
      text_for body.psub(placeholders)
    end

    def placeholders
      {
        sender: @pastel.inverse(@sender)
      }
    end

    def text_for(markdown)
      @raw ? markdown : TTY::Markdown.parse(markdown, mode: 16).strip
    end

  end
end
