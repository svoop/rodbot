# frozen-string-literal: true

require 'json'
require 'base64'

module Rodbot

  # Generic serializable chat message container
  #
  # The primary purpose of message objects is their ability to contain both
  # the actual message text as well as meta data such as the room in which the
  # message was or will be posted.
  #
  # Furthermore, they can be serialized (+dump+) and then recreated (+new+)
  # from that. You can also create a serialized message string outside of RodBot
  # performing the following steps:
  #
  # 1. Create a JSON hash which contains the keys +class+ (with static value
  #    +Rodbot::Message+), +text+ and optionally +room+.
  # 2. Encode it as Base64 without newlines.
  # 3. Prefix the result with the {PRELUDE}.
  #
  # Example for Shell:
  #   string='{"class":"Rodbot::Message",text":"hello, world","room":"general"}'
  #   string=$(echo $string | base64)
  #   string="data:application/json;base64,$string"
  #   echo $string
  class Message

    # Prelude string for serialized message objects
    PRELUDE = 'data:application/json;base64,'

    # Raw message text
    #
    # @return [String, nil]
    attr_reader :text

    # Room (aka: channel, group etc depending on the chat service) in which
    # the message was or will be posted
    #
    # @return [String, nil]
    attr_accessor :room

    # Initialize message from raw message text
    #
    # @param text [String] raw message text
    # @param room [String, nil] room in which the message was or will be posted
    def initialize(text, room: nil)
      @text, @room = text, room
    end

    # Initialize message from either message object previously serialized with
    # +dump+ or from raw message text
    #
    # @param string [String] string returned by +dump+ or raw message text
    # @param room [String, nil] room in which the message was or will be posted
    # @raise [ArgumentError] if the string is not valid Base64, JSON or does not
    #   contain the key +"class":"Rodbot::Message"+
    def self.new(string, room: nil)
      allocate.instance_eval do
        if string.match? /\A#{PRELUDE}/
          hash = JSON.load(Base64.strict_decode64(string.delete_prefix(PRELUDE)))
          fail(ArgumentError, "not a dumped message") unless hash['class'] == self.class.to_s
          initialize(hash['text'], room: room || hash['room'])
        else
          initialize(string, room: room)
        end
        self
      end
    rescue JSON::ParserError
      raise(ArgumentError, "invalid JSON")
    end

    # Serialize the message
    #
    # @return [String] serialized and encoded +self+
    def dump
      to_h.to_json.then { PRELUDE + Base64.strict_encode64(_1) }
    end

    # Convert message to Hash
    #
    # @return [Hash]
    def to_h
      { class: self.class.to_s, text: text, room: room }
    end

    # Whether two messages are equal
    #
    # @return [Boolean]
    def ==(other)
      to_h == other.to_h
    end

  end
end
