require_relative '../../../spec_helper'

describe Rodbot::Services::App do
  describe :bind do
    subject do
      Rodbot::Services::App.new
    end

    after do
      subject.instance_variable_set(:@bind, nil)
    end

    it "returns localhost and port 7200 by default" do
      _(subject.send(:bind)).must_equal ['localhost', 7200]
    end

    it "returns localhost and explicit port config" do
      with '@config', Rodbot::Config.new("port 8888"), on: Rodbot do
        _(subject.send(:bind)).must_equal ['localhost', 8888]
      end
    end

    it "returns value of RODBOT_APP_HOST and port 7200" do
      with "ENV['RODBOT_APP_HOST']", 'app.local' do
        _(subject.send(:bind)).must_equal ['app.local', 7200]
      end
    end
  end

  describe :url do
    subject do
      Rodbot::Services::App
    end

    after do
      subject.instance_variable_set(:@url, nil)
    end

    it "returns http://localhost:7200 by default" do
      _(subject.url).must_equal 'http://localhost:7200'
    end

    it "returns http://localhost and explicit port config" do
      with '@config', Rodbot::Config.new("port 8888"), on: Rodbot do
        _(subject.url).must_equal 'http://localhost:8888'
      end
    end

    it "returns value of RODBOT_APP_URL and port 7200" do
      with "ENV['RODBOT_APP_URL']", 'https://app.local' do
        _(subject.url).must_equal 'https://app.local:7200'
      end
    end
  end
end
