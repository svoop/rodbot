# frozen_string_literal: true

require_relative '../../spec_helper'

describe Rodbot::Serializer do
  subject do
    Rodbot::Serializer
  end

  describe :new do
    it "loads string (for deserialization)" do
      _(subject.new('')).must_be_instance_of subject
    end

    it "loads hash (for serialization)" do
      _(subject.new({})).must_be_instance_of subject
    end

    it "rejects other objects" do
      %i(:foobar, 123, Object.new).each do |object|
        _{ subject.new(object) }.must_raise ArgumentError
      end
    end
  end

  describe :string do
    it "returns loaded string" do
      string = 'foobar'
      _(subject.new(string).string).must_be_same_as string
    end

    it "returns serialized loaded hash" do
      _(subject.new({ 'foo' => 'bar' }).string).must_equal "data:application/json;base64,eyJmb28iOiJiYXIifQ=="
    end

    it "performs successful roundtrips" do
      hash = { 'foo' => 'bar' }
      _(subject.new(subject.new(hash).string).hash).must_equal hash
    end
  end

  describe :hash do
    it "returns loaded hash" do
      hash = { 'foo' => 'bar' }
      _(subject.new(hash).hash).must_be_same_as hash
    end

    it "fails if loaded string lacks prelude" do
      _{ subject.new('foobar').hash }.must_raise RuntimeError
    end

    it "fails if loaded string contains invalid Base64" do
      string = subject::PRELUDE + '&&&'
      _{ subject.new(string).hash }.must_raise RuntimeError
    end

    it "fails if loaded string contains invalid JSON" do
      string = subject::PRELUDE + Base64.strict_encode64('invalid')
      _{ subject.new(string).hash}.must_raise RuntimeError
    end
  end

  describe :serializable? do
    it "returns true if hash loaded" do
      _(subject.new({})).must_be :serializable?
    end

    it "returns false if string loaded" do
      _(subject.new('')).wont_be :serializable?
    end
  end

  describe :deserializable? do
    it "returns true if string with prelude loaded" do
      _(subject.new(subject::PRELUDE)).must_be :deserializable?
    end

    it "returns false if string without prelude loaded" do
      _(subject.new('')).wont_be :deserializable?
    end
  end
end
