# require the linux_spec_helper.rb file
# this sets up the ssh connection
require "#{ENV['SPEC_HELPER'] ? ENV['SPEC_HELPER'] : 'linux_spec_helper'}"

the_file = '/tmp/everything.txt'

if os[:family] == 'redhat'
    the_file = '/tmp/rhel-7'
end


describe "File #{the_file}" do
    subject(:f) { file(the_file) }
    it "exists" do
        expect(f).to exist
    end
    it "has 'our junk file data'" do
        expect(f.content).to match %r{^our junk file data$}
    end
end

# alternatively this could we written
# describe file(the_file) do
#    it { should exist }
#    its(:content) { should match %r{^woohoo saltconf18$} }
# end