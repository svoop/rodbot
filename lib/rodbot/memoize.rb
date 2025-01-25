# frozen_string_literal: true

module Rodbot

  # Memoize the return value of a specific method
  #
  # The method signature is taken into account, therefore calls of the same
  # method with different positional and/or keyword arguments are cached
  # independently. On the other hand, when calling the method with a block,
  # no memoization is performed at all.
  #
  # @example Explicit declaration
  #   class Either
  #     include Rodbot::Memoize
  #
  #     def either(argument=nil, keyword: nil, &block)
  #       $entropy || argument || keyword || (block.call if block)
  #     end
  #     memoize :either
  #   end
  #
  # @example Prefixed declaration
  #   class Either
  #     include Rodbot::Memoize
  #
  #     memoize def either(argument=nil, keyword: nil, &block)
  #       $entropy || argument || keyword || (block.call if block)
  #     end
  #   end
  #
  # @example Behaviour of either of the above
  #   e = Either.new
  #   $entropy = nil
  #   e.either(1)                 # => 1
  #   e.either(keyword: 2)        # => 2
  #   e.either { 3 }              # => 3
  #   $entropy = :not_nil
  #   e.either(1)                 # => 1          (memoized)
  #   e.either(keyword: 2)        # => 2          (memoized)
  #   e.either { 3 }              # => :not_nil   (cannot be memoized)
  #   Rodbot::Memoize.suspend do
  #     e.either(1)               # => 1          (recalculated, not memoized)
  #   end
  #   Rodbot::Memoize.revisit do
  #     e.either(5)               # => 5          (recalculated, memoized anew)
  #   end
  module Memoize
    module ClassMethods
      def memoize(method)
        unmemoized_method = :"_unmemoized_#{method}"
        alias_method unmemoized_method, method
        define_method method do |*args, **kargs, &block|
          if Rodbot::Memoize.suspend? || block
            send(unmemoized_method, *args, **kargs, &block)
          else
            cache = Rodbot::Memoize.cache
            id = object_id.hash ^ method.hash ^ args.hash ^ kargs.hash
            if !Rodbot::Memoize.revisit? && cache.has_key?(id)
              cache[id]
            else
              cache[id] = send(unmemoized_method, *args, **kargs)
            end
          end
        end
        method
      end
    end

    class << self
      attr_reader :cache

      def included(base)
        base.extend(ClassMethods)
        @cache ||= {}
      end

      %i(suspend revisit).each do |switch|
        ivar = "@#{switch}"
        define_method switch do |&block|
          instance_variable_set(ivar, true)
          block.call
        ensure
          instance_variable_set(ivar, false)
        end

        define_method "#{switch}?" do
          if instance_variable_defined? ivar
            instance_variable_get ivar
          else
            instance_variable_set(ivar, false)
          end
        end
      end
    end
  end

end
