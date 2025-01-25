# frozen_string_literal: true

require_relative '../../spec_helper'

describe Rodbot do
  it "must be defined" do
    _(Rodbot::VERSION).wont_be_nil
  end
end
