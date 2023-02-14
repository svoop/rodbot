# frozen_string_literal: true

require 'dry/cli'

require 'zeitwerk'
loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect 'cli' => 'CLI'
loader.setup

module Rodbot
end
