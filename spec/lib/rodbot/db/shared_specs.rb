module SharedSpecs
  def self.included(base)
    base.class_eval do

      describe :set do
        it "accepts block without argument to replace value" do
          subject.set(:foo) { 'bar' }
          subject.set(:foo) { 'baz' }
          _(subject.get(:foo)).must_equal 'baz'
        end

        it "accepts block with argument to extend value" do
          subject.set(:name) { 'John' }
          subject.set(:name) { |n| "#{n} Doe" }
          _(subject.get(:name)).must_equal 'John Doe'
        end

        it "accepts and enforces expires_in argument" do
          subject.set(:lifespan, expires_in: 1) { 'short' }
          _(subject.get(:lifespan)).must_equal 'short'
          sleep 1
          _(subject.get(:lifespan)).must_be :nil?
        end

        it "recognizes nested keys passed as String or Array of Symbols" do
          subject.set('foo:bar') { 'baz' }
          _(subject.get('foo:bar')).must_equal 'baz'
          subject.set(:foo, :bar) { 'baz' }
          _(subject.get('foo:bar')).must_equal 'baz'
        end

        it "returns the value (prior to serialization)" do
          _(subject.set(:name) { 'John' }).must_equal 'John'
          _(subject.set(:name) { |n| "#{n} Doe" }).must_equal 'John Doe'
        end
      end

      describe :get do
        it "returns deserialized value for known key" do
          ['John', 30, true].each do |value|
            subject.set(:value) { value }
            _(subject.get(:value)).must_equal value
          end
        end

        it "converts Symbol values to String" do
          subject.set(:foo) { :bar }
          _(subject.get(:foo)).must_equal 'bar'
        end

        it "converts Array element values from Symbol to String" do
          subject.set(:value) { ['foo', :bar, 123] }
          _(subject.get(:value)).must_equal ['foo', 'bar', 123]
        end

        it "converts Hash keys from String to Symbol" do
          subject.set(:value) { { :a => 1, 'b' => 2 } }
          _(subject.get(:value)).must_equal({ a: 1, b: 2 })
        end

        it "recognizes nested keys passed as String or Array of Symbols" do
          subject.set('foo:bar') { 'baz' }
          _(subject.get('foo:bar')).must_equal 'baz'
          _(subject.get(:foo, :bar)).must_equal 'baz'
        end

        it "returns nil for unknown key" do
          _(subject.get(:undefined)).must_be :nil?
        end
      end

      describe :delete do
        it "returns the current value and removes the key" do
          subject.set(:foo) { 'bar' }
          _(subject.delete(:foo)).must_equal 'bar'
          _(subject.delete(:foo)).must_be :nil?
        end

        it "recognizes nested keys passed as String or Array of Symbols" do
          subject.set('foo:bar') { 'baz' }
          _(subject.delete('foo:bar')).must_equal 'baz'
          subject.set('foo:bar') { 'baz' }
          _(subject.delete(:foo, :bar)).must_equal 'baz'
        end

        it "returns nil for unknown key" do
          _(subject.delete(:undefined)).must_be :nil?
        end
      end

      describe :scan do
        it "returns all keys matching the pattern" do
          subject.set(:color, :bike) { 'red' }
          subject.set(:color, :car) { 'blue' }
          subject.set(:shape, :bike) { 'narrow' }
          _(subject.scan(:color, :*).sort).must_equal %w(color:bike color:car)
          _(subject.scan(:shape, :*)).must_equal %w(shape:bike)
        end

        it "recognizes nested keys passed as String or Array of Symbols" do
          subject.set(:color, :bike) { 'red' }
          _(subject.scan('color:*')).must_equal ['color:bike']
          _(subject.scan(:color, :*)).must_equal ['color:bike']
        end

        it "returns an empty array if no matching keys are found" do
          _(subject.scan(:*)).must_equal []
        end
      end

      describe :flush do
        it "removes all keys" do
          subject.set(:color, :bike) { 'red' }
          subject.set(:color, :car) { 'blue' }
          subject.set(:shape, :bike) { 'narrow' }
          _(subject.scan(:*).count).must_equal 3
          subject.flush
          _(subject.scan(:*).count).must_equal 0
        end
      end

    end
  end
end
