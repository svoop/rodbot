require_relative '../../../spec_helper'
require_relative 'shared_specs'

describe Rodbot::Db::Hash do
  subject do
    Rodbot::Db.new('hash')
  end

  describe :prune do
    it "doesn't prune if threshold of set is not reached" do
      10.times { subject.set(_1, expires_in: -1) { true } }
      _(subject.send(:db).count).must_equal 10
    end

    it "does prune if threshold of set is reached" do
      105.times { subject.set(_1, expires_in: -1) { true } }
      _(subject.send(:db).count).must_equal 5
    end
  end

  include SharedSpecs
end
