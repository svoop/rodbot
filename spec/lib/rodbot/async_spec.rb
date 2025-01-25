# frozen_string_literal: true

require_relative '../../spec_helper'

# For testing, let's run the asynchronous jobs synchronously,
# see https://github.com/brandonhilkert/sucker_punch#testing
require 'sucker_punch'
require 'sucker_punch/testing/inline'

describe Rodbot::Async do
  subject do
    Rodbot::Async
  end

  describe :perform do
    it "yields synchronously in test environment" do
      yielded = false
      subject.perform { yielded = true }
      _(yielded).must_equal true
    end

    it "yields as an asynchronous job in non-test environment" do
      substitute '@current', 'production', on: Rodbot::Env do
        yielded = false
        subject.perform { yielded = true }
        _(yielded).must_equal true
      end
    end
  end
end
