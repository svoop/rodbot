# frozen_string_literal: true

require_relative '../../../spec_helper'

class Either
  include Rodbot::Memoize

  def either(argument=nil, keyword: nil, &block)
    $entropy || argument || keyword || (block.call if block)
  end
  memoize :either
end

describe Rodbot::Memoize do
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

  describe :suspend do
    it "recalculates but doesn't memoize when wrapped with suspend block" do
      _(subject.either(1)).must_equal 1
      $entropy = :not_nil
      Rodbot::Memoize.suspend do
        _(subject.either(1)).must_equal :not_nil
      end
      _(subject.either(1)).must_equal 1
    end
  end

  describe :revisit do
    it "recalculates and memoizes when wrapped with revisit block" do
      _(subject.either(1)).must_equal 1
      $entropy = :not_nil
      Rodbot::Memoize.revisit do
        _(subject.either(1)).must_equal :not_nil
      end
      _(subject.either(1)).must_equal :not_nil
    end
  end
end
