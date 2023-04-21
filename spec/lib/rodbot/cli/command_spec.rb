require_relative '../../../spec_helper'

describe Rodbot::CLI::Command do
  subject do
    Rodbot::CLI::Command.new
  end

  describe :error do
    it "writes the error message to STDERR" do
      with '$stderr', File.new('/dev/null', 'w'), assign: '.reopen' do
        _(subject.send(:error, 'foobar')).must_output 'foobar'
      rescue SystemExit
      end
    end

    it "exits with non-zero status" do
      with '$stderr', File.new(File::NULL, 'w'), assign: '.reopen' do
        exit_code = _{ subject.send(:error, 'foobar') }.must_raise SystemExit
        _(exit_code.status).wont_equal 0
      end
    end
  end
end
