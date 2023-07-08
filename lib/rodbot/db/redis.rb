# frozen_string_literal: true

module Rodbot
  class Db

    # Database adapter for Redis
    #
    # All keys are implicitly nested inside the "rodbot:..." namespace to allow
    # using one and the same Redis db for more than just Rodbot.
    #
    # @example Enable in config/rodbot.rb
    #   db 'redis://localhost:6379/10'
    module Redis
      def self.extended(*)
        require 'redis'
      end

      def set(*key, expires_in: nil, &block)
        block.call((get(*key) unless block.arity.zero?)).tap do |value|
          db.set(skey(*key), serialize(value), ex: expires_in)
        end
      end

      def get(*key)
        deserialize(db.get(skey(*key)))
      end

      def delete(*key)
        get(*key).tap do
          db.del(skey(*key))
        end
      end

      def scan(*key)
        cursor, result = 0, []
        loop do
          cursor, keys = db.scan(cursor, match: skey(*key))
          result.append(*keys)
          break result if cursor == '0'
        end.map { _1[7..] }
      end

      def flush
        db.flushdb
        self
      end

      private

      def db
        @db ||= ::Redis.new(url: url)
      end

      def skey(*key)
        key.prepend('rodbot').join(':')
      end
    end
  end
end
