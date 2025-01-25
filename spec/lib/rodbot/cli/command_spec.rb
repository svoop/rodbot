# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Rodbot::CLI::Command do
  subject do
    Rodbot::CLI::Command.new
  end

  describe :error do
    it "exits with non-zero status" do
      stderr_memo = $stderr
      $stderr.reopen File.new(File::NULL, 'w')
      exit_code = _{ subject.send(:error, 'foobar') }.must_raise SystemExit
      _(exit_code.status).wont_equal 0
      $stderr.reopen stderr_memo
    end
  end
end
