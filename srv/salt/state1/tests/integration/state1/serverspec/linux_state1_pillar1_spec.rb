# require the linux_spec_helper.rb file
# this sets up the ssh connection
require 'linux_spec_helper'

the_file = '/tmp/everything.txt'

if os[:family] == 'redhat'
    the_file = '/tmp/rhel-7'
end


describe "File #{the_file}" do
    subject(:f) { file(the_file) }
    it "exists" do
        expect(f).to exist
    end
    it "has 'saltconf18!'" do
        expect(f.content).to match %r{^saltconf18!$}
    end
end

# alternatively this could we written
# describe file(the_file) do
#    it { should exist }
#    its(:content) { should match %r{^woohoo saltconf18$} }
# end