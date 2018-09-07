require 'win_spec_helper'

the_file = 'c:\all-windows.txt'


describe "File #{the_file}" do
    subject(:f) { file(the_file) }
    it "exists" do
        expect(f).to exist
    end
    it "has 'our junk file data'" do
        expect(f.content).to match %r{^our junk file data$}
    end
end
