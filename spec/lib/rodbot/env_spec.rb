require_relative '../../spec_helper'

describe Rodbot::Env do
  subject do
    Rodbot::Env.new
  end

  describe :root do
    it "returns the current directory by default" do
      _(subject.root).must_equal Pathname.pwd
    end

    it "returns the explicitly initialized and normalized root dirctory" do
      dir = Pathname(Dir.tmpdir).realpath.to_s
      subject = Rodbot::Env.new(root: dir)
      _(subject.root).must_equal Pathname(dir)
    end
  end

  describe :tmp do
    it "returns the tmp directory in root" do
      _(subject.tmp).must_equal Pathname.pwd.join('tmp')
    end
  end

  describe :gem do
    it "returns the gem root directory" do
      _(subject.gem).must_be_instance_of Pathname
      _(subject.gem.to_s).must_match(%r(/rodbot$))
    end
  end

  Rodbot::Env::ENVS.each do |env|
    describe "#{env}?" do
      it "returns a boolean" do
        _(subject.send("#{env}?").to_s).must_match(/true|false/)
      end
    end
  end

  describe 'RODBOT_ENV environment variable' do
    it "sets the environment" do
      _(subject).must_be :test?
      _(subject).wont_be :development?
      _(subject).wont_be :production?
    end

    it "defaults to development" do
      with "ENV['RODBOT_ENV']", 'unset or invalid' do
        _(subject).must_be :development?
      end
    end
  end

  describe :split? do
    it 'returns false if RODBOT_SPLIT is not "true"' do
      with 'ENV["RODBOT_SPLIT"]', 'false' do
        _(subject).wont_be :split?
      end
    end

    it 'returns true if RODBOT_SPLIT is "true"' do
      with 'ENV["RODBOT_SPLIT"]', 'true' do
        _(subject).must_be :split?
      end
    end
  end
end
