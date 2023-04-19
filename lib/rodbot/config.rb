module Rodbot

  # Simple yet flexible configuration module
  #
  # The configuration is defined in Ruby as follows:
  #
  #   name 'Bot'
  #   country 'Sweden'
  #   country nil
  #   plugin :matrix do
  #     version 1
  #     ssl true
  #   end
  #   plugin :slack do
  #     version 2
  #   end
  #
  # Once this configuration file is read, it can be queried using the shortcut
  # getter +Rodbot.config+:
  #
  #   Rodbot::Config.read 'config/rodbot.rb'
  #   Rodbot.config(:name)        # => 'Bot'
  #   Rodbot.config(:country)     # => nil
  #   Rodbot.config(:undefined)   # => nil
  #   Rodbot.config(:plugin, :matrix, :version)
  #   # => 1
  #   Rodbot.config(:plugin, :matrix)
  #   # => { version: 1, ssl: true }
  #   Rodbot.config(:plugin)
  #   # => { matrix: { version: 1, ssl: true }, slack: { version: 2 } }
  #   Rodbot.config
  #   # => { name: 'Bot', country: nil, plugin: { matrix: { version: 1, ssl: true }, slack: { version: 2 } } }
  #
  # As you see, the same key can be used multiple times, but the result depends
  # on whether a block is present or not:
  #
  # * simple values (without block) -> all but the last assignment are ignored
  # * nested values (with block) -> every key creates a new subtree
  module Config
    extend self

    # Read configuration from file
    #
    # @param file [Object] any object which responds to +read+
    # @return [self]
    def read(file)
      @config = Reader.new.eval_file(file).to_h
      self
    end

    # Get config values and subtrees
    #
    # @note Use the +Rodbot.config+ shortcut to access this method!
    #
    # @param keys [Array] key path to config subtree or value
    # @return [Object] config subtree or value
    def config(*keys)
      return @config if keys.none?
      value = @config.dig(*keys)
      if value.instance_of?(Array) && value.count == 1
        value.first
      else
        value
      end
    end

    class Reader
      def initialize
        @hash = {}
      end

      # Eval configuration from file
      #
      # @param file [Object] any object which responds to +read+
      # @return [self]
      def eval_file(file)
        instance_eval file.read
        self
      end

      # Eval configuration from block
      #
      # @yield block to evaluate
      # @return [self]
      def eval_block(&block)
        instance_eval &block
        self
      end

      # Set an config value
      #
      # @param key [Symbol] config key
      # @param value [Object] config value
      # @yield optional block containing nested config
      # @return [self]
      def method_missing(key, value, *, &block)
        if block
          @hash[key] ||= {}
          @hash[key][value] = self.class.new.eval_block(&block).to_h
        else
          @hash[key] = value
        end
        self
      end

      # Config hash
      #
      # @return [Hash]
      def to_h
        @hash
      end
    end
  end
end
