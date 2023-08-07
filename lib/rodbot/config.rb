# frozen-string-literal: true

module Rodbot

  # Simple yet flexible configuration module
  #
  # The configuration is defined in Ruby as follows:
  #
  #   name 'Bot'
  #   country 'Sweden'
  #   country nil
  #   log do
  #     level 3
  #   end
  #   plugin :matrix do
  #     version 1
  #     ssl true
  #   end
  #   plugin :slack do
  #     version 2
  #   end
  #
  # Within Rodbot, you should use the +Rodbot.config+ shortcut to access the
  # configuration.
  #
  #   file = File.new('config/rodbot.rb')
  #   rc = Rodbot::Config.new(file.read)
  #   rc.config(:name)        # => 'Bot'
  #   rc.config(:country)     # => nil
  #   rc.config(:undefined)   # => nil
  #   rc.config(:log)         # => { level: 3 }
  #   rc.config(:plugin, :matrix, :version)
  #   # => 1
  #   rc.config(:plugin, :matrix)
  #   # => { version: 1, ssl: true }
  #   rc.config(:plugin)
  #   # => { matrix: { version: 1, ssl: true }, slack: { version: 2 } }
  #   rc.config
  #   # => { name: 'Bot', country: nil, plugin: { matrix: { version: 1, ssl: true }, slack: { version: 2 } } }
  #
  # There are two types configuration items:
  #
  # 1. Object values without block like +name 'Bot'+:<br>The config key +:name+
  #    gets the object +'Bot'+ assigned. Subsequent assignments with the same
  #    config key overwrite previous assignments.
  # 2. Unspecified value with a block like +log do+:<br>The config key +:log+ is
  #    assigned a hash defined by the block. Subsequent assignments with the
  #    same config key are merged into the hash.
  # 3. Object values with a block like +plugin :matrix do+:<br>The config key
  #    +:plugin+ is assigned an empty hash which is then populated with the
  #    object `:matrix` (usually a Symbol) as key and the subtree defined by the
  #    block. Subsequent assignments with the same config key add more keys to
  #    this hash.
  #
  # Please note: You can force a config key to always be treated as if it had
  # a block (type 3) by adding it to the +KEYS_WITH_IMPLICIT_BLOCK+ array.
  #
  # Defaults set by the +DEFAULTS+ constant are read first and therefore may be
  # overwritten or extend as mentioned above.
  class Config

    # Keys which are always treated as if they had a block even if they don't
    KEYS_WITH_IMPLICIT_BLOCK = %i(plugin).freeze

    # Default configuration
    DEFAULTS = <<~END
      name 'Rodbot'
      port 7200
      timezone 'Etc/UTC'
      db 'hash'
      app do
        threads Rodbot.env.development? ? (1..1) : (2..4)
      end
      log do
        to STDOUT
        level Rodbot.env.development? ? Logger::INFO : Logger::ERROR
      end
    END

    # Read configuration from file
    #
    # @param source [String] config source e.g. read from +config/rodbot.rb+
    # @param defaults [Boolean] whether to load the defaults or not
    # @return [self]
    def initialize(source, defaults: true)
      @config = Reader.new.eval_strings((DEFAULTS if defaults), source).to_h
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

      # Eval configuration from strings
      #
      # @param strings [String, nil] one or more strings to evaluate
      # @return [self]
      def eval_strings(*strings)
        instance_eval(strings.compact.join("\n"))
        self
      end

      # Eval configuration from block
      #
      # @yield block to evaluate
      # @return [self]
      def eval_block(&block)
        instance_eval(&block) if block
        self
      end

      # Set an config value
      #
      # @param key [Symbol] config key
      # @param value [Object, nil] config value
      # @yield optional block containing nested config
      # @return [self]
      def method_missing(key, value=nil, *, &block)
        case
        when block && value.nil?
          @hash[key] ||= {}
          @hash[key].merge! self.class.new.eval_block(&block).to_h
        when block || KEYS_WITH_IMPLICIT_BLOCK.include?(key)
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
