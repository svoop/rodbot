# frozen_string_literal: true

module Rodbot
  class Db

    # Database adapter for Hash
    #
    # @example Enable in config/rodbot.rb
    #   db 'hash'
    #
    # This database is for development and testing only, it is not thread-safe
    # and therefore should not be used in production.
    module Hash
      PRUNE_THRESHOLD = 100

      def set(*key, expires_in: nil, &block)
        prune
        block.call((get(*key) unless block.arity.zero?)).tap do |value|
          db[key.join(':')] = [
            serialize(value),
            (epoch + expires_in if expires_in)
          ]
        end
      end

      def get(*key)
        value, expires_at = db[skey(*key)]
        deserialize(value) if value && (!expires_at || epoch < expires_at)
      end

      def delete(*key)
        value, expires_at = db.delete(skey(*key))
        deserialize(value) if value && (!expires_at || epoch < expires_at)
      end

      def scan(*key)
        re = /\A#{skey(*key).sub(/\*\z/, '')}/
        db.keys.select { _1.match? re }
      end

      def flush
        @db = {}
        self
      end

      private

      def db
        @db ||= {}
      end

      def skey(*key)
        key.join(':')
      end

      def epoch
        Time.now.to_f
      end

      def prune
        @counter ||= 0
        if (@counter += 1) > PRUNE_THRESHOLD
          cached_epoch = epoch
          db.delete_if { _2.last < cached_epoch }
          @counter = 1
        end
      end
    end

  end
end
