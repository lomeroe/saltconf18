# a shared example with file_data having a default that matches 
# the defaults from the defaults.yml
# one thing to be careful of, your pillar values need to start with
# a lowercase character or they will be considered constants
# by ruby and you will not be able to edit them
shared_examples 'state1::linux' do | file_data: 'our junk file data',
                                     **kwargs |
    the_file = '/tmp/everything.txt'

    if os[:family] == 'redhat'
        the_file = '/tmp/rhel-7'
    end
    
    describe "File #{the_file}" do
        subject(:f) { file(the_file) }
        it "exists" do
            expect(f).to exist
        end
        it "has '#{file_data}'" do
            expect(f.content).to match %r{^#{file_data}$}
        end
    end
end