# frozen_string_literal: true

require_relative '../../spec_helper'

using Rodbot::Refinements

describe Rodbot::Refinements do
  subject do
    Rodbot::Refinements
  end

  context String do
    describe :camelize do
      it "converts an underscored string to camelcase" do
        _('foo_bar'.camelize).must_equal 'FooBar'
      end

      it "leaves an empty string unchanged" do
        _(''.camelize).must_equal ''
      end
    end

    describe :constantize do
      it "resolves a simple constant path" do
        _('string'.constantize).must_equal String
      end

      it "resolves a namespaced costant path" do
        _('rodbot/plugins'.constantize).must_equal Rodbot::Plugins
      end

      it "fails on inexistant constants" do
        _{ 'rodbot/does_not_exist'.constantize }.must_raise NameError
      end
    end
  end

  describe :uri_concat do
    subject do
      'http://example.com'
    end

    it "returns unchanged URI if no path segment is given" do
      _(subject.uri_concat).must_equal 'http://example.com'
    end

    it "concats one ASCII path segment" do
      _(subject.uri_concat('foo')).must_equal 'http://example.com/foo'
    end

    it "concats one ASCII path segment with extension" do
      _(subject.uri_concat('foo.html')).must_equal 'http://example.com/foo.html'
    end

    it "concats multiple ASCII path segments" do
      _(subject.uri_concat('foo/', 'bar/')).must_equal 'http://example.com/foo/bar/'
    end

    it "concats multiple ASCII path segments with extension" do
      _(subject.uri_concat('foo/', 'bar.html')).must_equal 'http://example.com/foo/bar.html'
    end

    it "encodes non-ASCII path segments" do
      _(subject.uri_concat('föö')).must_equal 'http://example.com/f%C3%B6%C3%B6'
    end

    it "encodes unsafe path segments" do
      _(subject.uri_concat('foo#bar')).must_equal 'http://example.com/foo%23bar'
    end
  end

  describe :md_to_html do
    it "converts Markdown to HTML" do
      _('**important**'.md_to_html).must_equal '<p><strong>important</strong></p>'
    end
  end

  describe :html_to_text do
    it "removes HTML tags" do
      _('<p><strong>important</strong></p>'.html_to_text).must_equal 'important'
    end

    it "doesn't remove placeholders like [[SENDER]]" do
      _('<p>[[SENDER]]</p>'.html_to_text).must_equal '[[SENDER]]'
    end
  end

  describe :psub do
    it "replaces placeholders like [[SENDER]]" do
      placeholders = { sender: 'Oggy' }
      _('Hi, [[SENDER]]!'.psub(placeholders)).must_equal 'Hi, Oggy!'
    end

    it "replaces undefined placeholder with empty string" do
      placeholders = { dusk: 8, sunset: 19 }
      _('from [[DUSK]] till [[DAWN]]'.psub(placeholders)).must_equal 'from 8 till '
    end
  end

  describe :inflector do
    it "returns a Zeitwerk::Inflector instance" do
      _(subject.inflector).must_be_instance_of Zeitwerk::Inflector
    end
  end
end
