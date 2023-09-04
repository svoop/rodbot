require_relative '../../../../spec_helper'

module Minitest
  class SpecOtp < App
    route do |r|
      r.get 'password' do
        r.send(:password)
      end

      r.get 'valid_otp' do
        r.valid_otp?.to_s
      end

      r.get 'require_valid_otp' do
        r.require_valid_otp!
        ''
      end
    end
  end

  App.run :spec_otp, SpecOtp
end


describe 'plugin :otp' do
  let :secret do
    ROTP::Base32.random
  end

  let :current_otp do
    ROTP::TOTP.new(secret, issuer: 'Rodbot').now
  end

  describe :password do
    it "extracts the password" do
      with '@config', Rodbot::Config.new("plugin :otp do; secret '#{secret}'; end"), on: Rodbot do
        _(app_request("/spec_otp/password?arguments=foobar+#{current_otp}").body).must_equal current_otp
      end
    end
  end

  describe :valid_otp? do
    it "rejects missing OTP" do
      _(app_request('/spec_otp/valid_otp').body).must_equal 'false'
    end

    it "rejects wrong OTP" do
      _(app_request('/spec_otp/valid_otp?arguments=foobar+xxxxxx').body).must_equal 'false'
    end

    it "accepts correct OTP" do
      with '@config', Rodbot::Config.new("plugin :otp do; secret '#{secret}'; end"), on: Rodbot do
        _(app_request("/spec_otp/valid_otp?arguments=foobar+#{current_otp}").body).must_equal 'true'
      end
    end

    it "rejects duplicate correct OTP" do
      with '@config', Rodbot::Config.new("plugin :otp do; secret '#{secret}'; end"), on: Rodbot do
        _(app_request("/spec_otp/valid_otp?arguments=foobar+#{current_otp}").body).must_equal 'true'
        _(app_request("/spec_otp/valid_otp?arguments=foobar+#{current_otp}").body).must_equal 'false'
      end
    end
  end

  describe :require_valid_otp! do
    it "does nothing on correct OTP" do
      with '@config', Rodbot::Config.new("plugin :otp do; secret '#{secret}'; end"), on: Rodbot do
        _(app_request("/spec_otp/require_valid_otp?arguments=foobar+#{current_otp}").status).must_equal 200
      end
    end

    it "responds with 401 on wrong OTP" do
      with '@config', Rodbot::Config.new("plugin :otp do; secret '#{secret}'; end"), on: Rodbot do
        _(app_request("/spec_otp/require_valid_otp?arguments=foobar+xxxxxx").status).must_equal 401
      end
    end
  end
end
