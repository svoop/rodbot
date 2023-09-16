require_relative '../../../../spec_helper'

module Minitest
  class SpecOtp < App
    route do |r|
      r.get 'arguments' do
        r.valid_otp?
        r.send(:arguments)
      end

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
  before do
    Rodbot.db.flush
  end

  let :secret do
    Rodbot.config(:plugin, :otp, :secret)   # current secret reset every time in rodbot.rb
  end

  let :current_otp do
    ROTP::TOTP.new(secret, issuer: 'Rodbot').now
  end

  describe :arguments do
    it "contains the arguments without the password" do
      _(app_request("/spec_otp/arguments?arguments=foobar+#{current_otp}").body).must_equal 'foobar'
    end
  end

  describe :password do
    it "extracts the password" do
      _(app_request("/spec_otp/password?arguments=foobar+#{current_otp}").body).must_equal current_otp
    end
  end

  describe :valid_otp? do
    it "rejects missing OTP" do
      _(app_request('/spec_otp/valid_otp').body).must_equal 'false'
    end

    it "rejects wrong OTP" do
      _(app_request('/spec_otp/valid_otp?arguments=foobar+000000').body).must_equal 'false'
    end

    it "accepts correct OTP" do
      _(app_request("/spec_otp/valid_otp?arguments=foobar+#{current_otp}").body).must_equal 'true'
    end

    it "rejects duplicate correct OTP" do
      _(app_request("/spec_otp/valid_otp?arguments=foobar+#{current_otp}").body).must_equal 'true'
      _(app_request("/spec_otp/valid_otp?arguments=foobar+#{current_otp}").body).must_equal 'false'
    end
  end

  describe :require_valid_otp! do
    it "does nothing on correct OTP" do
      _(app_request("/spec_otp/require_valid_otp?arguments=foobar+#{current_otp}").status).must_equal 200
    end

    it "responds with 401 on wrong OTP" do
      _(app_request("/spec_otp/require_valid_otp?arguments=foobar+000000").status).must_equal 401
    end
  end
end
