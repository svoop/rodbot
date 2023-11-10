require_relative '../../spec_helper'

describe Rodbot::Generator do
  subject do
    Rodbot::Generator.new(spec_dir.join('fixtures', 'generator'))
  end

  describe :display do
    it "prints all interpolated templates to STDOUT" do
      _{ subject.display }.must_output <<~END

        ### test/test.md ###
        **Markdown**

        ### test.erb ###
        <%= 'ERB' %> with GERB

        ### test.html ###
        HTML with GERB

        ### test.txt ###
        Plain text

      END
    end
  end

  describe :write do
    it "writes all interpolated templates to the filesystem" do
      Dir.mktmpdir do |temp_dir|
        target_path = Pathname(temp_dir).join('target')
        _{ subject.write(target_path) }.must_output <<~END
          [create] test/test.md
          [create] test.erb
          [create] test.html
          [create] test.txt
        END
        _(target_path.join('test', 'test.md').read).must_equal "**Markdown**\n"
        _(target_path.join('test.erb').read).must_equal "<%= 'ERB' %> with GERB\n"
        _(target_path.join('test.html').read).must_equal "HTML with GERB\n"
        _(target_path.join('test.txt').read).must_equal "Plain text\n"
      end
    end

    it "fails if the target path exists already" do
      Dir.mktmpdir do |temp_dir|
        _{ subject.write(Pathname(temp_dir)) }.must_raise Rodbot::GeneratorError
      end
    end
  end

  describe :each_template_path do
    it "returns a globbed array of GERB and non-GERB templates" do
      yielded_args = ''
      subject.send(:each_template_path) do |*args|
        yielded_args << args.join("\n") << "\n---\n"
      end
      yielded_args = yielded_args.gsub(spec_dir.to_s, '')
      _(yielded_args).must_equal <<~END
        /fixtures/generator/test/test.md
        test/test.md

        ---
        /fixtures/generator/test.erb.gerb
        test.erb
        <%= 'ERB' %> with GERB

        ---
        /fixtures/generator/test.html.gerb
        test.html
        HTML with GERB

        ---
        /fixtures/generator/test.txt
        test.txt

        ---
      END
    end
  end

  describe :eval_gerb do
    it "accepts trim syntax" do
      _(subject.send(:eval_gerb, '[%= "ok" -%]')).must_equal 'ok'
    end

    it "makes helpers avaiable" do
      _(subject.send(:eval_gerb, '[%= time_zone %]')).must_equal 'Etc/UTC'
    end
  end

  describe :tag do
    it "returns tagged (and colorized) string" do
      _(subject.send(:tag, :create, 'foobar')).must_equal "[create] foobar"
    end
  end
end

describe Rodbot::Generator::Helpers do
  subject do
    Rodbot::Generator::Helpers.new
  end

  describe :time_zone do
    it "returns the configured timezone" do
      _(subject.time_zone).must_equal 'Etc/UTC'
    end
  end

  describe :relay_extensions do
    with '@config', on: Rodbot do
      Rodbot::Config.new('plugin :matrix')
    end

    it "returns map from relay name to port" do
      _(subject.relay_extensions).must_equal({ matrix: 7201 })
    end
  end
end
