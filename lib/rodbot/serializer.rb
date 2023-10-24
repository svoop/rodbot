# frozen-string-literal: true

require 'json'
require 'base64'

module Rodbot

  # Simple yet safe Hash to String serializer
  #
  # Keep in mind that hash keys will always be deserialized as strings!
  #
  # Example:
  #   hash = { 'foo' => 'bar' }
  #   string = Serializer.new(hash).string
  #   # => "data:application/json;base64,eyJmb28iOiJiYXIifQ=="
  #   hash = Serializer.new(string).hash
  #   # => { 'foo' => 'bar' }
  class Serializer

    # Prelude string for serialized hash
    PRELUDE = 'data:application/json;base64,'

    # @params object [Hash, String] either a Hash (to serialize) or a String
    #   (to deserialize)
    def initialize(object)
      case object
        when Hash then @hash = object
        when String then @string = object
        else fail ArgumentError, "must be either Hash or String"
      end
    end

    # @return [String] Hash serialized to String
    def string
      @string ||= begin
        fail "object is not serializable" unless serializable?
        @hash.to_json.then { PRELUDE + Base64.strict_encode64(_1) }
      end
    end

    # @return [Hash] String deserialized to Hash
    # @raise [RuntimeError] when deserialization fails
    def hash
      @hash ||= begin
        fail "object is not deserializable" unless deserializable?
        JSON.load(Base64.strict_decode64(@string.delete_prefix(PRELUDE)))
      end
    rescue ArgumentError
      raise "invalid Base64"
    rescue JSON::ParserError
      raise "invalid JSON"
    end

    # @return [Boolean] whether the object passed with +new+ is serializable
    def serializable?
      !!@hash
    end

    # @return [Boolean] whether the object passed with +new+ is deserializable
    def deserializable?
      @string && @string.match?(/\A#{PRELUDE}/)
    end

  end
end
