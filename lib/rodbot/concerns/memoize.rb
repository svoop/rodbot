module Rodbot
  module Concerns

    # Memoize the return value of a specific method
    #
    # The method signature is taken into account, therefore calls of the same
    # method with different positional and/or keyword arguments are cached
    # independently. On the other hand, when calling the method with a block,
    # no memoization is performed at all.
    #
    # Memoization is completely disabled in the +test+ environment.
    #
    # @example Explicit declaration
    #   class Either
    #     include Rodbot::Concerns::Memoize
    #
    #     def either(argument=nil, keyword: nil, &block)
    #       $entropy || argument || keyword || (block.call if block)
    #     end
    #     memoize :either
    #   end
    #
    # @example Prefixed declaration
    #   class Either
    #     include Rodbot::Concerns::Memoize
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
    module Memoize
      module ClassMethods
        def memoize(method, disabled: Rodbot.env.test?)
          unless disabled
            unmemoized_method = :"_unmemoized_#{method}"
            alias_method unmemoized_method, method
            define_method method do |*args, **kargs, &block|
              if block
                send(unmemoized_method, *args, **kargs, &block)
              else
                id = method.hash ^ args.hash ^ kargs.hash
                @_memoize_cache ||= {}
                if @_memoize_cache.has_key? id
                  @_memoize_cache[id]
                else
                  @_memoize_cache[id] = send(unmemoized_method, *args, **kargs)
                end
              end
            end
          end
          method
        end
      end

      class << self
        def included(base)
          base.extend(ClassMethods)
        end
      end
    end

  end
end
