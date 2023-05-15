require_relative '../../../spec_helper'
require_relative 'shared_specs'

describe Rodbot::Db::Redis do
  if ENV['RODBOT_SPEC_REDIS_URL']
    subject do
      Rodbot::Db.new(ENV['RODBOT_SPEC_REDIS_URL']).tap do |db|
        db.flush
      end
    end

    include SharedSpecs
  else
    it "implements the Redis backend" do
      skip
    end
  end
end
