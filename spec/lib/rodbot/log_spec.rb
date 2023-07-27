require_relative '../../spec_helper'

describe Rodbot::Log do
  subject do
    Rodbot::Log.new
  end

  describe :log do
    it "writes to default log" do
      mock_logger = Minitest::Mock.new.expect(:log, true) do |level, message|
        true
      end
      with :@default_logger, mock_logger, on: subject do
        subject.instance_variable_set(:@default_logger, mock_logger)
        _(subject.log('log message')).must_equal true
        _(mock_logger.verify).must_equal true
      end
    end
  end

  describe :logger do
    it "returns a new Logger instance" do
      _(Rodbot::Log.logger('test')).must_be_instance_of Logger
    end
  end

  describe :std? do
    it "returns true if logging is configured to STDOUT" do
      _(Rodbot::Log).must_be :std?
    end

    it "returns true if logging is configured to STDERR" do
      Rodbot.stub(:config, STDERR) do
        _(Rodbot::Log).must_be :std?
      end
    end

    it "returns false if logging is configured to any other IO" do
      Rodbot.stub(:config, '/tmp/test.log') do
        _(Rodbot::Log).wont_be :std?
      end
    end
  end
end

describe Rodbot::Log::LoggerIO do
  describe :write do
    it "simulates IO by forwarding write to log" do
      mock_logger = Minitest::Mock.new.expect(:log, true) do |level, message|
        level == 1 && message == 'log message'
      end
      subject = Rodbot::Log::LoggerIO.new(mock_logger, 1)
      _(subject.write('log message')).must_equal true
      _(mock_logger.verify).must_equal true
    end
  end
end
