require_relative '../../spec_helper'

describe Rodbot::Env do
  subject do
    Rodbot::Env
  end

  describe :root do
    it "returns the root directory" do
      _(subject.root).must_be_instance_of Pathname
    end
  end

  describe :loader do
    it "returns a Zeitwerk loader" do
      _(subject.loader).must_be_instance_of Zeitwerk::Loader
    end
  end

  Rodbot::Env::ENVS.each do |env|
    describe "#{env}?" do
      it "returns a boolean" do
        _(subject.send("#{env}?").to_s).must_match(/true|false/)
      end
    end
  end

  describe 'RODBOT_ENV variable' do
    it "sets the environment" do
      _(subject).must_be :test?
      _(subject).wont_be :development?
      _(subject).wont_be :production?
    end

    it "defaults to development" do
      subject.instance_variable_set(:@current_env, nil)
      ENV['RODBOT_ENV'] = nil
      _(subject).must_be :development?
      subject.instance_variable_set(:@current_env, nil)
      ENV['RODBOT_ENV'] = 'test'
      _(subject).must_be :test?
    end
  end
end
