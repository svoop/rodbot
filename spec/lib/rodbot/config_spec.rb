require_relative '../../spec_helper'

require 'stringio'

describe Rodbot::Config do
  let :source do
    <<~END
      name 'Bot'
      country 'Sweden'
      country nil
      log do
        level 3
      end
      plugin :slack
      plugin :matrix do
        version 1
        ssl true
      end
      template :light do
        color 'white'
      end
      template :dark do
        color 'black'
      end
    END
  end

  subject do
    Rodbot::Config.new(source, defaults: false)
  end

  describe :initialize do
    it "honors the DEFAULTS by default" do
      subject = Rodbot::Config.new(source)
      _(subject.config(:time_zone)).must_equal 'Etc/UTC'
      _(subject.config(:name)).must_equal 'Bot'
    end

    it "ignores the DEFAULTS if defaults is false" do
      _(subject.config(:time_zone)).must_be :nil?
      _(subject.config(:name)).must_equal 'Bot'
    end

    it "accetpts IO by reading from it" do
      io = StringIO.new(source)
      io.instance_eval do
        def readable?
          true
        end
      end
      subject = Rodbot::Config.new(io)
      _(subject.config(:time_zone)).must_equal 'Etc/UTC'
      _(subject.config(:name)).must_equal 'Bot'
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
      _(subject.config(:log, :level)).must_equal 3
      _(subject.config(:plugin, :matrix, :version)).must_equal 1
      _(subject.config(:plugin, :matrix, :ssl)).must_equal true
      _(subject.config(:template, :light, :color)).must_equal 'white'
    end

    it "returns nested subtrees from KEYS_WITH_IMPLICIT_BLOCK" do
      _(subject.config(:plugin)).must_equal({
        slack: {},
        matrix: { version: 1, ssl: true }
      })
      _(subject.config(:plugin, :matrix)).must_equal({
        version: 1, ssl: true
      })
    end

    it "returns nested subtrees" do
      _(subject.config(:template)).must_equal({
        light: { color: 'white' },
        dark: { color: 'black' }
      })
    end

    it "returns the entire config hash if no keys are given" do
      _(subject.config).must_equal({
        name: 'Bot',
        country: nil,
        log: { level: 3 },
        plugin: {
          slack: {},
          matrix: { version: 1, ssl: true }
        },
        template: {
          light: { color: 'white' },
          dark: { color: 'black' }
        }
      })
    end
  end
end

describe Rodbot::Config::Reader do
  subject do
    Rodbot::Config::Reader.new
  end

  describe :eval_strings do
    it "evaluate one string" do
      _(subject.eval_strings("name :oggy").to_h).must_equal({ name: :oggy })
    end

    it "evaluate multiple strings" do
      _(subject.eval_strings("dog :oggy", "cat :froufrou").to_h).must_equal({ dog: :oggy, cat: :froufrou })
    end

    it "ignores nil" do
      _(subject.eval_strings("name :oggy", nil).to_h).must_equal({ name: :oggy })
    end
  end

  describe :eval_block do
    it "evaluates the block" do
      proc = Proc.new { name :oggy }
      _(subject.eval_block(&proc).to_h).must_equal({ name: :oggy })
    end
  end

  describe :method_missing do
    context "without block (defines overwritable simple value)" do
      it "assigns a value when used once" do
        _(subject.color('red').to_h).must_equal({ color: 'red' })
      end

      it "overwrites with a new value when used repeatedly" do
        _(subject.color('red').color('blue').to_h).must_equal({ color: 'blue' })
      end
    end

    context "with block" do
      context "without value (defines extensible hash)" do
        it "assigns a hash when used once" do
          _(subject.log(nil) { level 2 }.to_h).must_equal({
            log: {
              level: 2
            }
          })
        end

        it "merges hash when used repeatedly" do
          _(subject.log(nil) { level 2 }.log(nil) { level 3 }.log(nil) { sublevel 12 }.to_h).must_equal({
            log: {
              level: 3,
              sublevel: 12
            }
          })
        end
      end

      context "with value (defines extensible hash in hash)" do
        it "assigns one subtree hash when used once" do
          _(subject.plugin(:screen) { type 1 }.to_h).must_equal({
            plugin: {
              screen: {
                type: 1
              }
            }
          })
        end

        it "assigns multiple subtree hashes when used repeatedly" do
          _(subject.plugin(:screen) { type 1 }.plugin(:print) { type 2 }.to_h).must_equal({
            plugin: {
              screen: {
                type: 1
              },
              print: {
                type: 2
              }
            }
          })
        end
      end
    end
  end

  describe :to_h do
    it "returns an empty hash by default" do
      _(subject.to_h).must_equal({})
    end
  end
end
