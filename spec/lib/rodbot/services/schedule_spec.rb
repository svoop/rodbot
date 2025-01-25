# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Rodbot::Services::Schedule do
  subject do
    Rodbot::Services::Schedule.new
  end

  describe :run do
    it 'should start the schedule service' do
      Clockwork.stub(:run, :called) do
        _(subject.send(:run)).must_equal :called
      end
    end
  end
end
