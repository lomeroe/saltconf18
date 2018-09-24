require "#{ENV['SPEC_HELPER'] ? ENV['SPEC_HELPER'] : 'linux_spec_helper'}"
require "#{File.join(File.dirname(__FILE__), 'state1_shared')}"
require 'get_pillar_data'

if $pillar_data.has_key? :local and $pillar_data[:local].has_key? :state1
    # check for common-defaults and merge if we do
    example_options = $pillar_data[:local][:state1]
else
    example_options = Hash.new
end

describe "State shared 1 tests" do
    include_examples 'state1::linux', example_options
end