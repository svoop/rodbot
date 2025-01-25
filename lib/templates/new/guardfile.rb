# frozen_string_literal: true

clearing :on

guard :minitest do
  %i(services).each do |dir|
    watch(%r{^spec/#{dir}/(.+)_spec\.rb})
    watch(%r{^#{dir}/(.+)\.rb}) { "spec/#{dir}/#{_1[1]}_spec.rb" }
  end
  watch(%r{^spec/spec_helper\.rb}) { 'spec' }
end
