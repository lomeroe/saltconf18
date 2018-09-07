# require the 'win_spec_helper.rb' file
# this file sets up the winrm connection
require 'win_spec_helper'

the_file = 'c:\all-windows.txt'


describe "File #{the_file}" do
    subject(:f) { file(the_file) }
    it "exists" do
        expect(f).to exist
    end
    it "has 'wohoo saltconf18'" do
        expect(f.content).to match %r{^woohoo saltconf18$}
    end
end

# alternatively this could we written
# describe file(the_file) do
#    it { should exist }
#    its(:content) { should match %r{^woohoo saltconf18$} }
# end