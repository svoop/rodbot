# frozen_string_literal: true

require_relative '../../spec_helper'

describe Rodbot::Simulator do
  context 'not raw' do
    subject do
      Rodbot::Simulator.new('tester')
    end

    describe :reply_to do
      it "returns warning if no command is present" do
        _(subject.send(:reply_to, 'foobar')).must_equal '(no command given)'
      end

      it "handles 404 error from the app" do
        mock_response = Minitest::Mock.new.expect(:status, 404)
        Rodbot.stub(:request, mock_response) do
          _(subject.send(:reply_to, '!unknown')).must_match(/I don.t know what do do with/)
          _(mock_response.verify).must_equal true
        end
      end

      it "handles other errors from the app" do
        mock_response = Minitest::Mock.new.expect(:status, 500)
        Rodbot.stub(:request, mock_response) do
          _(subject.send(:reply_to, '!broken')).must_match(/I.m having trouble talking to the app/)
          _(mock_response.verify).must_equal true
        end
      end

      it "returns the response body" do
        mock_response = Minitest::Mock.new.expect(:status, 200).expect(:body, 'hello')
        Rodbot.stub(:request, mock_response) do
          _(subject.send(:reply_to, '!known')).must_equal 'hello'
          _(mock_response.verify).must_equal true
        end
      end

      it "interpolates [[SENDER]] in the response body" do
        mock_response = Minitest::Mock.new.expect(:status, 200).expect(:body, 'hello [[SENDER]]')
        Rodbot.stub(:request, mock_response) do
          _(subject.send(:reply_to, '!known')).must_equal 'hello tester'
          _(mock_response.verify).must_equal true
        end
      end

      it "converts Markdown in the response body" do
        mock_response = Minitest::Mock.new.expect(:status, 200).expect(:body, '* list')
        Rodbot.stub(:request, mock_response) do
          _(subject.send(:reply_to, '!known')).must_equal '● list'
          _(mock_response.verify).must_equal true
        end
      end
    end

    describe :text_for do
      it "returns resolved Markdown" do
        _(subject.send(:text_for, '* list')).must_equal '● list'
      end
    end
  end

  context 'raw' do
    subject do
      Rodbot::Simulator.new('test', raw: true)
    end

    describe :reply_to do
      it "returns raw Markdown in the response body" do
        mock_response = Minitest::Mock.new.expect(:status, 200).expect(:body, '* hello')
        Rodbot.stub(:request, mock_response) do
          _(subject.send(:reply_to, '!known')).must_equal '* hello'
          _(mock_response.verify).must_equal true
        end
      end
    end

    describe :text_for do
      it "returns raw Markdown" do
        _(subject.send(:text_for, '**bold**')).must_equal '**bold**'
      end
    end
  end
end
