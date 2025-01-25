# frozen_string_literal: true

require_relative '../../spec_helper'

describe Rodbot::Db do
  subject do
    Rodbot::Db
  end

  describe :initialize do
    it "sets the URL instance variable" do
      _(subject.new('hash').url).must_equal 'hash'
    end

    it "mixes in the backend adapter module" do
      _(subject.new('hash').respond_to?(:set)).must_equal true
    end
  end
end
