# frozen_string_literal: true

require 'json'

using Rodbot::Refinements

module Rodbot

  # Uniform key/value database interface for various backends
  #
  # Keys can be namespaced using the colon as separator:
  #
  # * 'color' - color key without namespace
  # * 'bike:color' - color key within the bike namespace
  # * 'vehicle:bike:color' - color key within... you get the idea
  #
  # Furthermore, keys can be entered either as colon separated keys or as
  # list of symbols. The following are therefore equivalent:
  #
  #   Rodbot.db.get('vehicle:bike:color')
  #   Rodbot.db.get(:vehicle, :bike, :color)
  #
  # Same goes for the star wildcard which is only allowed last:
  #
  #   Rodbot.db.scan('vehicle:*')
  #   Rodbot.db.scan(:vehicle, :*)
  #
  # The interface is simple and straightforward:
  #
  # @example Set a value
  #   Rodbot.db.set(:name) { 'John' }
  #
  # @example Set a value which expires after 30 seconds
  #   Rodbot.db.set(:name, expires_in: 30) { 'John' }
  #
  # @example Replace an existing value
  #   Rodbot.db.set(:name) { 'John' }
  #   Rodbot.db.set(:name) { 'Bob' }   # replaces John with Bob
  #
  # @example Update an existing value
  #   Rodbot.db.set(:name) { 'John' }
  #   Rodbot.db.set(:name) { |n| "#{n} Doe" }   # replaces John with John Doe
  #
  # @example Get a value
  #   Rodbot.db.set(:name) { 'John' }
  #   Rodbot.db.get(:name)   # => 'John'
  #
  # @example Delete a value
  #   Rodbot.db.set(:name) { 'John' }
  #   Rodbot.db.delete(:name)   # => 'John'
  #   Rodbot.db.get(:name)      # => nil
  #
  # @example Scan for keys
  #   Rodbot.db.set(:first_name) { 'John' }
  #   Rodbot.db.set(:last_name) { 'Doe' }
  #   Rodbot.db.scan(:*)   # => [:first_name, :last_name]
  #
  # @example Delete all keys
  #   Rodbot.db.flush
  #
  # Please note that {JSON} is used to serialize which has an influence on
  # what you get back after deserialization:
  #
  # * Primitive types such as String, Integer or TrueClass are preserved.
  # * Any other object is converted to String, incuding...
  # * Symbol values are converted to String
  # * Symbol elements in an array are converted to String
  # * Symbol values in a hash are converted to String
  #
  # However, hash keys are always converted to Symbol - mainly because Rubyland
  # favours Symbol keys over String keys for visual reasons.
  class Db
    attr_reader :url

    # @param url [String] connection URL of the backend
    def initialize(url)
      @url = url
      extend "rodbot/db/#{url.split('://').first}".constantize
    end

    private

    def serialize(object)
      object.to_json
    end

    def deserialize(string)
      JSON.parse(string, symbolize_names: true) if string
    end
  end
end
