require_relative '../../spec_helper'

require 'stringio'

describe Rodbot::Config do
  subject do
    io = StringIO.new <<~END
      name 'Bot'
      country 'Sweden'
      country nil
      plugin :matrix do
        version 1
        ssl true
      end
      plugin :slack do
        version 2
      end
    END
    Rodbot::Config.read(io)
  end

  describe :read do
    it "reads the file" do
      _(subject).must_be_kind_of Rodbot::Config
    end
  end

  describe :config do
    it "returns nil for undefined keys" do
      _(subject.config(:foo)).must_be :nil?
      _(subject.config(:foo, :bar)).must_be :nil?
    end

    it "returns unnested values" do
      _(subject.config(:name)).must_equal 'Bot'
      _(subject.config(:counry)).must_be :nil?
    end

    it "returns nested values" do
      _(subject.config(:plugin, :matrix, :version)).must_equal 1
      _(subject.config(:plugin, :matrix, :ssl)).must_equal true
      _(subject.config(:plugin, :slack, :version)).must_equal 2
      _(subject.config(:plugin, :slack, :ssl)).must_be :nil?
    end

    it "returns nested subtrees" do
      _(subject.config(:plugin)).must_equal({ matrix: { version: 1, ssl: true }, slack: { version: 2 } })
      _(subject.config(:plugin, :matrix)).must_equal({ version: 1, ssl: true })
    end

    it "returns the entire config hash if no keys are given" do
      _(subject.config).must_equal({ name: 'Bot', country: nil, plugin: { matrix: { version: 1, ssl: true }, slack: { version: 2 } } })
    end
  end

  describe Rodbot::Config::Reader do
    subject do
      Rodbot::Config::Reader.new
    end

    describe :eval_file do
      it "reads and evaluates the file" do
        io = StringIO.new("name :oggy")
        _(subject.eval_file(io).to_h).must_equal({ name: :oggy })
      end
    end

    describe :eval_block do
      it "evaluates the block" do
        proc = Proc.new { name :oggy }
        _(subject.eval_block(&proc).to_h).must_equal({ name: :oggy })
      end
    end

    describe :method_missing do
      context "without block" do
        it "assigns a value when used once" do
          _(subject.color('red').to_h).must_equal({ color: 'red' })
        end

        it "overwrites with a new value when used repeatedly" do
          _(subject.color('red').color('blue').to_h).must_equal({ color: 'blue' })
        end
      end

      context "with block" do
        it "assigns one subtree hash when used once" do
          _(subject.plugin(:screen) { type 1 }.to_h).must_equal({ plugin: { screen: { type: 1 } } })
        end

        it "assigns multiple subtree hashes when used repeatedly" do
          _(subject.plugin(:screen) { type 1 }.plugin(:print) { type 2 }.to_h).must_equal({ plugin: { screen: { type: 1 }, print: { type: 2 } } })
        end
      end
    end

    describe :to_h do
      it "returns an empty hash by default" do
        _(subject.to_h).must_equal({})
      end
    end
  end
end
