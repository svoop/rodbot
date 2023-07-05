# frozen-string-literal: true

require 'fileutils'
require 'erb'
require 'pastel'

module Rodbot

  # Generators for new bots, deployments and such
  #
  # All files inside the +templates_path+ are honoured provided they match the
  # {GLOB}. Files with the extension ".gerb" are parsed like ERB files, however,
  # GERB tags must use square brackets.
  #
  #   ERB:  <%= 'foobar' %>
  #   GERB: [%= 'foobar' %]
  #
  # It's therefore possible to generate ERB files such as +index.erb.gerb+.
  #
  # Helpers available in GERB templates have to be defined in
  # {Rodbot::Generator::Helpers}.
  class Generator

    # Glob to filter relevant template files
    GLOB = "**/{*,.ruby-version,.gitignore,.keep}"

    # Colors used by +info+ to color part of the output
    TAG_COLORS = {
      create: :green
    }.freeze

    # @param templates_path [Pathname] root path of the templates to generate from
    def initialize(templates_path)
      @templates_path = templates_path
      @helpers_binding = Helpers.new.instance_eval('binding')
      @pastel = Pastel.new
    end

    # Print the interpolated template to STDOUT
    def display
      each_template_path do |template_path, target_path, content|
        puts "# #{target_path}", (content || template_path.read)
      end
    end

    # Write the interpolated template to directory
    #
    # @param directory [Pathname] where to write the files to
    def write(directory)
      fail(Rodbot::GeneratorError, "cowardly refusing to write to existing #{directory}") if directory.exist?
      each_template_path do |template_path, target_path, content|
        absolute_target_path = directory.join(target_path)
        absolute_target_path.dirname.mkpath
        puts tag(:create, target_path)
        if content
          absolute_target_path.write(content)
        else
          FileUtils.copy(template_path, absolute_target_path)
        end
      end
    end

    private

    def each_template_path
      @templates_path.glob(GLOB).each do |template_path|
        next unless template_path.file?
        target_path = template_path.relative_path_from(@templates_path)
        content = if template_path.extname == '.gerb'
          target_path = target_path.dirname.join(target_path.basename('.gerb'))
          eval_gerb(template_path.read)
        end
        yield(template_path, target_path, content)
      end
    end

    def eval_gerb(string)
      ungerbify(ERB.new(gerbify(string), trim_mode: '-').result(@helpers_binding))
    end

    def gerbify(string)
      string.gsub('<%', '{%').gsub('%>', '%}').gsub('[%', '<%').gsub('%]', '%>')
    end

    def ungerbify(string)
      string.gsub('{%', '<%').gsub('%}', '%>')
    end

    def tag(tag, string)
      padded_tag = '[' + tag.to_s.ljust(6, ' ') + '] '
      @pastel.decorate(padded_tag, TAG_COLORS[tag]) + string.to_s.strip
    end

    class Helpers
      def timezone
        Rodbot.config(:timezone)
      end

      def relay_extensions
        Rodbot.plugins.extend_relay
        Rodbot.plugins.extensions[:relay].to_h do |name, _|
          [name, Rodbot::Relay.bind_for(name).last]
        end
      end
    end

  end
end
