require_relative '../../../../spec_helper'

describe 'plugin :hal' do
  subject do
    app_request('/hal')
  end

  context "GET /hal" do
    it "accepts the request" do
      _(subject.status).must_equal 200
    end

    it "responds with an easter egg" do
      _(subject.body).must_match(/I'm afraid I can't do that/)
    end
  end
end
