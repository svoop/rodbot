require_relative '../../../spec_helper'

class Either
  include Rodbot::Concerns::Memoize

  def either(argument=nil, keyword: nil, &block)
    $entropy || argument || keyword || (block.call if block)
  end
  memoize :either, disabled: false
end

describe Rodbot::Concerns::Memoize do
  subject do
    Either.new
  end

  before do
    $entropy = nil
  end

  describe :memoize do
    it "memoizes non-nil return values" do
      _(subject.either(1)).must_equal 1
      $entropy = :not_nil
      _(subject.either(1)).must_equal 1
      _(subject.either(2)).must_equal :not_nil
    end

    it "memoizes nil return values" do
      _(subject.either(nil)).must_be :nil?
      $entropy = :not_nil
      _(subject.either(nil)).must_be :nil?
      _(subject.either(2)).must_equal :not_nil
    end

    it "memoizes per positional argument" do
      _(subject.either(1)).must_equal 1
      $entropy = :not_nil
      _(subject.either(1)).must_equal 1
    end

    it "memoizes per keyword argument" do
      _(subject.either(keyword: 1)).must_equal 1
      $entropy = :not_nil
      _(subject.either(keyword: 1)).must_equal 1
    end

    it "cannot memoize per block" do
      _(subject.either { 1 }).must_equal 1
      $entropy = :not_nil
      _(subject.either { 1 }).must_equal :not_nil
    end
  end
end
