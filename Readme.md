# Saltconf18

#### pytest setup

Install the salt minion

Install the pytest module via pip/package manager

For windows, install via salt's pip:
```
c:\salt\salt-call state.single pip.installed name=pytest cwd='c:\salt\bin\scripts' bin_env='c:\salt\bin\scripts\pip.exe'
```

#### test-kitchen setup

Install ruby via package manager (linux) or from rubyinstaller.org (windows)

Install additional module requirements via `gem`
```
gem install serverspec kitchen-salt test-kitchen rspec_junit_formatter \
    kitchen-verifier-serverspec kitchen-ec2 winrm winrm-fs \
    win32-process net-ssh winrm-elevated win32-eventlog win32-service bundler
```

If you are using Windows and kitchen-ec2 (to create EC2s for test-kitchen to use)
you'll need to set the cert for SSL verification.  The Ruby path and/or gem path may be
slightly different based on versions you have installed/etc:
```
PS>$Env:SSL_CERT_FILE="C:\Ruby23-x64\lib\ruby\gems\2.3.0\gems\aws-sdk-core-2.6.14\ca-bundle.crt"
```

#### Executing a pytest run

Clone/download the repo to some location

Execute all pytest tests (assuming a windows system, with the repo downloaded to c:\temp)
```
PS c:\temp\saltconf18>c:\salt\bin\scripts\pytest.exe

============================= test session starts =============================
platform win32 -- Python 2.7.13, pytest-3.7.2, py-1.5.4, pluggy-0.7.1
rootdir: c:\temp\saltconf18, inifile: setup.cfg
plugins: spec-1.1.0
collected 10 items

srv\pillar\pillar1\tests\test_pillar1.py ..Fs                            [ 40%]
srv\salt\state1\tests\test_state1_show_sls.py ...                        [ 70%]
srv\salt\state2\tests\test_state2_show_sls.py FFF                        [100%]

================================== FAILURES ===================================
_____ test_pillar_values[None-grainUpdates2-pillar1-ubuntu-saltconf18-:] ______

saltCaller = <salt.client.Caller object at 0x0000000005FE9710>
pytestconfig = <_pytest.config.Config object at 0x0000000002FFAE80>
minionid = None, grainUpdates = [{'os': 'Ubuntu'}], pillar = 'pillar1'
expectedValue = 'ubuntu-saltconf18', pillarDelimiter = ':'

    @pytest.mark.parametrize("minionid,grainUpdates,pillar,expectedValue,pillarDelimiter",
            [
                (None, [{'os':'Windows'}], 'pillar1', 'windows-saltconf18', ':'),
                (None, [{'os':'RedHat'}], 'pillar1', 'redhat-saltconf18', ':'),
                (None, [{'os':'Ubuntu'}], 'pillar1', 'ubuntu-saltconf18', ':'),
                # specify a minion ID, a dict of grains to use, a pillar, a value, and a pillar delimiter
                # ('a_minion_id',[{'grain':'value'}],'some:pillar','expected_value_of_some:pillar',':'),
            ])
    def test_pillar_values(saltCaller, pytestconfig, minionid, grainUpdates, pillar, expectedValue, pillarDelimiter):
        '''
        this function will verify that a specified pillar has an expected values
        for a particular minionid/grain combo
        '''
        saltCaller.opts['file_roots']['base'] = [str(pytestconfig.rootdir.join('/srv/salt'))]
        saltCaller.opts['pillar_roots']['base'] = [str(pytestconfig.rootdir.join('/srv/pillar'))]
        if minionid:
            import salt.client
            saltCaller.opts['id'] = minionid
            saltCaller = salt.client.Caller(mopts=saltCaller.opts)
        if grainUpdates:
            for grainUpdate in grainUpdates:
                for k in grainUpdate.keys():
                    saltCaller.cmd('grains.setval', k, grainUpdate[k])
        pillarData = saltCaller.cmd('pillar.items')
        pillarSplit = pillar.split(pillarDelimiter)
        for i in pillarSplit:
          pillarData = pillarData[i]
>       assert pillarData == expectedValue
E       AssertionError: assert 'ubutnu-saltconf18' == 'ubuntu-saltconf18'
E         - ubutnu-saltconf18
E         ?     -
E         + ubuntu-saltconf18
E         ?    +

srv\pillar\pillar1\tests\test_pillar1.py:31: AssertionError
________________________ test_show_sls[RedHat-7-None] _________________________

saltCaller = <salt.client.Caller object at 0x0000000006EDB2E8>
pytestconfig = <_pytest.config.Config object at 0x0000000002FFAE80>
os_family = 'RedHat', osmajorrelease = '7', pillar = None

    @pytest.mark.parametrize("os_family,osmajorrelease,pillar", [
            ('RedHat', '7', None),
            ('Windows', '2016Server', None),
            ('Windows', '2012ServerR2', None)])
    def test_show_sls(saltCaller, pytestconfig, os_family, osmajorrelease, pillar):
        saltCaller.opts['file_roots']['base'] = [str(pytestconfig.rootdir.join('/srv/salt'))]
        if os_family:
            saltCaller.cmd('grains.setval', 'os_family', os_family)
        if osmajorrelease:
            saltCaller.cmd('grains.setval', 'osmajorrelease', osmajorrelease)
            saltCaller.cmd('grains.setval', 'osrelease', osmajorrelease)
        ret = saltCaller.cmd('state.show_sls', 'state2', pillar=pillar)
>       assert type(ret) in [dict, salt.utils.odict.OrderedDict]
E       assert <type 'list'> in [<type 'dict'>, <class 'salt.utils.odict.OrderedDict'>]
E        +  where <type 'list'> = type(["Rendering SLS 'base:state2' failed: Illegal tab character; line 4\n\n---\nmanage_tmp_file:\
n  file.managed:\n    - n...===================\n    - template: jinja\n    - defaults:\n        data: |\n            our junk file
data\x00\n---"])

srv\salt\state2\tests\test_state2_show_sls.py:17: AssertionError
---------------------------- Captured stdout call -----------------------------
STDOUT: Rendering SLS 'base:state2' failed: Illegal tab character; line 4

---
manage_tmp_file:
  file.managed:
    - name: '/tmp/rhel-7'
        - source: salt://state2/files/file.jinja    <======================
    - template: jinja
    - defaults:
        data: |
            our junk file data
---
------------------------------ Captured log call ------------------------------
state.py                  3265 CRITICAL Rendering SLS 'base:state2' failed: Illegal tab character; line 4

---
manage_tmp_file:
  file.managed:
    - name: '/tmp/rhel-7'
        - source: salt://state2/files/file.jinja    <======================
    - template: jinja
    - defaults:
        data: |
            our junk file data
---
___________________ test_show_sls[Windows-2016Server-None] ____________________

saltCaller = <salt.client.Caller object at 0x00000000064BA2E8>
pytestconfig = <_pytest.config.Config object at 0x0000000002FFAE80>
os_family = 'Windows', osmajorrelease = '2016Server', pillar = None

    @pytest.mark.parametrize("os_family,osmajorrelease,pillar", [
            ('RedHat', '7', None),
            ('Windows', '2016Server', None),
            ('Windows', '2012ServerR2', None)])
    def test_show_sls(saltCaller, pytestconfig, os_family, osmajorrelease, pillar):
        saltCaller.opts['file_roots']['base'] = [str(pytestconfig.rootdir.join('/srv/salt'))]
        if os_family:
            saltCaller.cmd('grains.setval', 'os_family', os_family)
        if osmajorrelease:
            saltCaller.cmd('grains.setval', 'osmajorrelease', osmajorrelease)
            saltCaller.cmd('grains.setval', 'osrelease', osmajorrelease)
        ret = saltCaller.cmd('state.show_sls', 'state2', pillar=pillar)
>       assert type(ret) in [dict, salt.utils.odict.OrderedDict]
E       assert <type 'list'> in [<type 'dict'>, <class 'salt.utils.odict.OrderedDict'>]
E        +  where <type 'list'> = type(["Rendering SLS 'base:state2' failed: Illegal tab character; line 4\n\n---\nmanage_tmp_file:\
n  file.managed:\n    - n...===================\n    - template: jinja\n    - defaults:\n        data: |\n            our junk file
data\x00\n---"])

srv\salt\state2\tests\test_state2_show_sls.py:17: AssertionError
---------------------------- Captured stdout call -----------------------------
STDOUT: Rendering SLS 'base:state2' failed: Illegal tab character; line 4

---
manage_tmp_file:
  file.managed:
    - name: 'c:/all-windows.txt'
        - source: salt://state2/files/file.jinja    <======================
    - template: jinja
    - defaults:
        data: |
            our junk file data
---
------------------------------ Captured log call ------------------------------
state.py                  3265 CRITICAL Rendering SLS 'base:state2' failed: Illegal tab character; line 4

---
manage_tmp_file:
  file.managed:
    - name: 'c:/all-windows.txt'
        - source: salt://state2/files/file.jinja    <======================
    - template: jinja
    - defaults:
        data: |
            our junk file data
---
__________________ test_show_sls[Windows-2012ServerR2-None] ___________________

saltCaller = <salt.client.Caller object at 0x00000000064266A0>
pytestconfig = <_pytest.config.Config object at 0x0000000002FFAE80>
os_family = 'Windows', osmajorrelease = '2012ServerR2', pillar = None

    @pytest.mark.parametrize("os_family,osmajorrelease,pillar", [
            ('RedHat', '7', None),
            ('Windows', '2016Server', None),
            ('Windows', '2012ServerR2', None)])
    def test_show_sls(saltCaller, pytestconfig, os_family, osmajorrelease, pillar):
        saltCaller.opts['file_roots']['base'] = [str(pytestconfig.rootdir.join('/srv/salt'))]
        if os_family:
            saltCaller.cmd('grains.setval', 'os_family', os_family)
        if osmajorrelease:
            saltCaller.cmd('grains.setval', 'osmajorrelease', osmajorrelease)
            saltCaller.cmd('grains.setval', 'osrelease', osmajorrelease)
        ret = saltCaller.cmd('state.show_sls', 'state2', pillar=pillar)
>       assert type(ret) in [dict, salt.utils.odict.OrderedDict]
E       assert <type 'list'> in [<type 'dict'>, <class 'salt.utils.odict.OrderedDict'>]
E        +  where <type 'list'> = type(["Rendering SLS 'base:state2' failed: Illegal tab character; line 4\n\n---\nmanage_tmp_file:\
n  file.managed:\n    - n...===================\n    - template: jinja\n    - defaults:\n        data: |\n            our junk file
data\x00\n---"])

srv\salt\state2\tests\test_state2_show_sls.py:17: AssertionError
---------------------------- Captured stdout call -----------------------------
STDOUT: Rendering SLS 'base:state2' failed: Illegal tab character; line 4

---
manage_tmp_file:
  file.managed:
    - name: 'c:/all-windows.txt'
        - source: salt://state2/files/file.jinja    <======================
    - template: jinja
    - defaults:
        data: |
            our junk file data
---
------------------------------ Captured log call ------------------------------
state.py                  3265 CRITICAL Rendering SLS 'base:state2' failed: Illegal tab character; line 4

---
manage_tmp_file:
  file.managed:
    - name: 'c:/all-windows.txt'
        - source: salt://state2/files/file.jinja    <======================
    - template: jinja
    - defaults:
        data: |
            our junk file data
---
=============== 4 failed, 5 passed, 1 skipped in 79.34 seconds ================
```

Execute only state1 tests:
```
PS C:\temp\saltconf18> C:\salt\bin\scripts\pytest.exe .\srv\salt\state1\
============================= test session starts =============================
platform win32 -- Python 2.7.13, pytest-3.7.2, py-1.5.4, pluggy-0.7.1
rootdir: C:\temp\saltconf18, inifile: setup.cfg
plugins: spec-1.1.0
collected 3 items

srv\salt\state1\tests\test_state1_show_sls.py ...                        [100%]

========================== 3 passed in 30.69 seconds ==========================
```

#### executing a test-kitchen run

Clone/download the repo to some location

Show all suite/platform combos (windows system with repo cloned into c:\temp):
```
PS c:\temp\saltconf18\srv\salt>kitchen list
Instance                                            Driver  Provisioner  Verifier    Transport  Last Action    Last Error
state1-win-windows-2012r2-salt-2018-3-py2-ec2       Ec2     SaltSolo     Serverspec  Winrm      <Not Created>  <None>
state1-win-windows-2016-salt-2018-3-py2-ec2         Ec2     SaltSolo     Serverspec  Winrm      <Not Created>  <None>
state1-win-windows-2012r2-salt-2018-3-py3-ec2       Ec2     SaltSolo     Serverspec  Winrm      <Not Created>  <None>
state1-win-windows-2016-salt-2018-3-py3-ec2         Ec2     SaltSolo     Serverspec  Winrm      <Not Created>  <None>
state1-win-windows-2012r2-salt-2017-7-py2-ec2       Ec2     SaltSolo     Serverspec  Winrm      <Not Created>  <None>
state1-win-windows-2016-salt-2017-7-py2-ec2         Ec2     SaltSolo     Serverspec  Winrm      <Not Created>  <None>
state1-win-windows-2012r2-salt-2017-7-py3-ec2       Ec2     SaltSolo     Serverspec  Winrm      <Not Created>  <None>
state1-win-windows-2016-salt-2017-7-py3-ec2         Ec2     SaltSolo     Serverspec  Winrm      <Not Created>  <None>
state1-win-pillar-windows-2016-salt-2018-3-py2-ec2  Ec2     SaltSolo     Serverspec  Winrm      <Not Created>  <None>
state1-linux-ubuntu-1804-salt-latest-ec2            Ec2     SaltSolo     Serverspec  Ssh        <Not Created>  <None>
state1-linux-centos-7-salt-latest-ec2               Ec2     SaltSolo     Serverspec  Ssh        <Not Created>  <None>
```

Test state1 on ubuntu 18.04:
```
PS c:\temp\saltconf18\srv\salt>kitchen test state1-linux-ubuntu-1804-salt-latest-ec2
PS C:\Users\Administrator\Desktop\saltconf18\srv\salt> kitchen test state1-linux-ubuntu-1804-salt-latest-ec2
-----> Starting Kitchen (v1.23.2)
-----> Cleaning up any prior instances of <state1-linux-ubuntu-1804-salt-latest-ec2>
-----> Destroying <state1-linux-ubuntu-1804-salt-latest-ec2>...
       EC2 instance <i-xxxx> destroyed.
       Finished destroying <state1-linux-ubuntu-1804-salt-latest-ec2> (0m1.67s).
-----> Testing <state1-linux-ubuntu-1804-salt-latest-ec2>
-----> Creating <state1-linux-ubuntu-1804-salt-latest-ec2>...
       instance_type not specified. Using free tier t2.micro instance ...
       Detected platform: ubuntu version 18.04 on x86_64. Instance Type: t2.micro. Default username: ubuntu (default).
       If you are not using an account that qualifies under the AWS
free-tier, you may be charged to run these suites. The charge
should be minimal, but neither Test Kitchen nor its maintainers
are responsible for your incurred costs.

       Instance <i-xxxx> requested.
       Polling AWS for existence, attempt 0...
       Attempting to tag the instance, 0 retries
       EC2 instance <i-xxxx> created.
       Waited 0/600s for instance <i-xxxx> volumes to be ready.
       Waited 0/600s for instance <i-xxxx> to become ready.
       Waited 10/600s for instance <i-xxxx> to become ready.
       Waited 20/600s for instance <i-xxxx> to become ready.
       Waited 30/600s for instance <i-xxxx> to become ready.
       EC2 instance <i-xxxx> ready (hostname: 10.10.10.10).
       Waiting for SSH service on 10.10.10.10:22, retrying in 3 seconds
<snip>
       Waiting for SSH service on 10.10.10.10:22, retrying in 3 seconds
       [SSH] Established
       Finished creating <state1-linux-ubuntu-1804-salt-latest-ec2> (12m51.38s).
-----> Converging <state1-linux-ubuntu-1804-salt-latest-ec2>...
       Preparing files for transfer
       Preparing salt-minion
       Preparing pillars into /srv/pillar
       Preparing state collection
       neither collection_name or formula have been set, assuming this is a pre-built collection
       Preparing state_top
       Preparing scripts into /etc/salt/scripts
       Generating locales (this might take a while)...
         en_US.UTF-8... done
       Generation complete.
       You asked for latest and you have 2018.3.2 installed, sweet!
       Transferring files to <state1-linux-ubuntu-1804-salt-latest-ec2>
       Install External Dependencies
       Content of /tmp/kitchen//srv/salt :
       total 64
       drwxr-xr-x 6 ubuntu ubuntu  4096 Sep  7 18:24 .
       drwxr-xr-x 3 ubuntu ubuntu  4096 Sep  7 18:24 ..
       drwxr-xr-x 3 ubuntu ubuntu  4096 Sep  7 18:24 .kitchen
       -rw-r--r-- 1 ubuntu ubuntu 33395 Sep  7 18:24 .kitchen.yml
       drwxr-xr-x 4 ubuntu ubuntu  4096 Sep  7 18:24 state1
       drwxr-xr-x 4 ubuntu ubuntu  4096 Sep  7 18:24 state2
       drwxr-xr-x 3 ubuntu ubuntu  4096 Sep  7 18:24 tests
       -rw-r--r-- 1 ubuntu ubuntu    28 Sep  7 18:24 top.sls
       local:
       ----------
                 ID: manage_tmp_file
           Function: file.managed
               Name: /tmp/everything.txt
             Result: True
            Comment: File /tmp/everything.txt updated
            Started: 18:24:26.224009
           Duration: 469.811 ms
            Changes:
              ----------
              diff:
                  New file
              mode:
                  0644

       Summary for local
       ------------
       Succeeded: 1 (changed=1)
       Failed:    0
       ------------
       Total states run:     1
       Total run time: 469.811 ms
       Downloading files from <state1-linux-ubuntu-1804-salt-latest-ec2>
       Finished converging <state1-linux-ubuntu-1804-salt-latest-ec2> (0m45.98s).
-----> Setting up <state1-linux-ubuntu-1804-salt-latest-ec2>...
       Finished setting up <state1-linux-ubuntu-1804-salt-latest-ec2> (0m0.00s).
-----> Verifying <state1-linux-ubuntu-1804-salt-latest-ec2>...
       Environment variable KITCHEN_USERNAME value ubuntu
       Environment variable KITCHEN_SERVER_ID value i-xxxx
       Environment variable KITCHEN_HOSTNAME value 10.10.10.10
       Environment variable KITCHEN_LAST_ACTION value setup
       Environment variable KITCHEN_LAST_ERROR value
       Transport Environment variable KITCHEN_USERNAME value root
       Transport Environment variable KITCHEN_SSH_KEY value C:/Users/Administrator/.ssh/kitchen-tester
       Transport Environment variable KITCHEN_PORT value 22
       Installing bundler and serverspec locally on workstation
       Running Serverspec
       Running command: rspec -c -f documentation --default-path  C:/temp/saltconf18/srv/salt -I tests/integration/serverspec -P **/tests/integration/state1/serverspec/linux_*defaults*_spec.rb


File /tmp/everything.txt
  exists
  has 'our junk file data'

Finished in 0.57813 seconds (files took 9.8 seconds to load)
2 examples, 0 failures

       Finished verifying <state1-linux-ubuntu-1804-salt-latest-ec2> (0m11.36s).
-----> Destroying <state1-linux-ubuntu-1804-salt-latest-ec2>...
       EC2 instance <i-xxxx> destroyed.
       Finished destroying <state1-linux-ubuntu-1804-salt-latest-ec2> (0m0.35s).
       Finished testing <state1-linux-ubuntu-1804-salt-latest-ec2> (13m50.79s).
-----> Kitchen is finished. (13m53.96s)
```

## Running rspec tests against non-kitchen managed nodes

One thing I like about having rspec tests written, is that on top of using them with test-kitchen, they can also be used against a system that was created by some other means (i.e. not by the test-kitchen process).  While using ``test=True`` on a ``state.apply`` can show us a lot of what may change or be needed for a minion, it can be lacking at times.  Other scenarios where this has been useful is testing a node for "standards" without needing to use salt at all (perhaps systems managed by some other group who doesn't use salt, but is interested how they match up with your standards).  The "documentation" output mode and well written tests can give you excellent, human-readable documentation of what your states/formulas are doing.  This output can be given to anyone (other admins, auditors, etc) showing how the node compares to your standards.

Running an rspec test against a live node is fairly simple and straight forward task:

We could use our same spec helpers that we created initially (```win_spec_helper``` and ```linux_spec_helper```), but I prefer to have a secondary helper for testing non-kitchen machines (I'll also have other reasons for this that I'll discuss in the pillar section below).

To use a custom helper, we'll modify our rspec test slightly.  The spec helper require will be modified with some string interpolation to use the default helper unless we select a different one with an environment variable.

Thus, the line requiring our helper 
```
require 'linux_spec_helper'
```
becomes
```
require "#{ENV['SPEC_HELPER'] ? ENV['SPEC_HELPER'] : 'linux_spec_helper'}"
```

With this, our test will use the ```linux_spec_helper``` unless we supply a different one to include through the ```SPEC_HELPER``` environment variable.

In this repository, there are two "custom" spec helpers named ```win_spec_helper_custom``` and ```linux_spec_helper_custom``` which will prompt you for information about the system to run the rspec tests against (if you take a peek at them, you could also supply the information via ```RSPEC_``` environment variables.

So, to use the custom spec helper against a linux node and run our "state1" tests (still assuming we're running this on a windows system and we have a copy of the repo on our 'Administrator' account's desktop):

```
PS C:\Users\Administrator\Desktop\saltconf18\srv\salt>$Env:SPEC_HELPER='linux_spec_helper_custom'
PS C:\Users\Administrator\Desktop\saltconf18\srv\salt>rspec -c --default-path c:/users/administrator/desktop/saltconf18/srv/salt -I .\tests\integration\serverspec -f documentation -P **\tests\integration\state1\serverspec\lin*default*spec.rb

Enter servername:  somehost
Enter username:  myusername
Enter a comma delimited set of auth methods (keyboard-interactive/publickey/hostbased/password) [publickey]:  keyboard-interactive
Enter password:
File /tmp/rhel-7
  exists (FAILED - 1)
  has 'our junk file data' (FAILED - 2)

File /tmp/rhel-7
  exists (FAILED - 3)
  has 'our junk file data' (FAILED - 4)

Failures:

  1) File /tmp/rhel-7 exists
     On host `somehost'
     Failure/Error: expect(f).to exist
       expected File "/tmp/rhel-7" to exist
       /bin/sh -c test\ -e\ /tmp/rhel-7

     # c:/Users/Administrator/Desktop/saltconf18/srv/salt/state1/tests/integration/state1/serverspec/linux_state1_defaults_spec.rb:15:in `block (2 levels) in <top (required)>'

  2) File /tmp/rhel-7 has 'our junk file data'
     On host `somehost'
     Failure/Error: expect(f.content).to match %r{^our junk file data$}
       expected "" to match /^our junk file data$/
       Diff:
       @@ -1,2 +1,2 @@
       -/^our junk file data$/
       +""

       /bin/sh -c cat\ /tmp/rhel-7\ 2\>\ /dev/null\ \|\|\ echo\ -n

     # c:/Users/Administrator/Desktop/saltconf18/srv/salt/state1/tests/integration/state1/serverspec/linux_state1_defaults_spec.rb:18:in `block (2 levels) in <top (required)>'

  3) File /tmp/rhel-7 exists
     On host `somehost'
     Failure/Error: expect(f).to exist
       expected File "/tmp/rhel-7" to exist
       /bin/sh -c test\ -e\ /tmp/rhel-7

     # C:/Users/Administrator/Desktop/saltconf18/srv/salt/state1/tests/integration/state1/serverspec/linux_state1_defaults_spec.rb:15:in `block (2 levels) in <top (required)>'

  4) File /tmp/rhel-7 has 'our junk file data'
     On host `somehost'
     Failure/Error: expect(f.content).to match %r{^our junk file data$}
       expected "" to match /^our junk file data$/
       Diff:
       @@ -1,2 +1,2 @@
       -/^our junk file data$/
       +""

       /bin/sh -c cat\ /tmp/rhel-7\ 2\>\ /dev/null\ \|\|\ echo\ -n

     # C:/Users/Administrator/Desktop/saltconf18/srv/salt/state1/tests/integration/state1/serverspec/linux_state1_defaults_spec.rb:18:in `block (2 levels) in <top (required)>'

Finished in 0.59376 seconds (files took 13.98 seconds to load)
4 examples, 4 failures

Failed examples:

rspec c:/Users/Administrator/Desktop/saltconf18/srv/salt/state1/tests/integration/state1/serverspec/linux_state1_defaults_spec.rb:14 # File /tmp/rhel-7 exists
rspec c:/Users/Administrator/Desktop/saltconf18/srv/salt/state1/tests/integration/state1/serverspec/linux_state1_defaults_spec.rb:17 # File /tmp/rhel-7 has 'our junk file data'
rspec C:/Users/Administrator/Desktop/saltconf18/srv/salt/state1/tests/integration/state1/serverspec/linux_state1_defaults_spec.rb:14 # File /tmp/rhel-7 exists
rspec C:/Users/Administrator/Desktop/saltconf18/srv/salt/state1/tests/integration/state1/serverspec/linux_state1_defaults_spec.rb:17 # File /tmp/rhel-7 has 'our junk file data'
```

## Pillar usage in tests

A few people asked me about using pillar data to drive your rspec tests after my presentation, so I'm adding this info here...

Pillar data can be automatically pulled in to your rspec tests -- whether run via test-kitchen or when run against production (or non-kitchen created nodes).  This can be done by kitchen-test created nodes (who get their pillar by definitions in ```.kitchen.yml```) or using our custom spec helpers against systems getting their pillar from a master.

The file ```get_pillar_data.rb``` has been added to the repo to handle getting the pillar.  This file runs a salt-call to get pillar data as json and then converts that json into a ruby hash.  Requiring this file in the test file will be step 1.  This file uses the environment variables ```KITCHEN_HOSTNAME``` and ```KITCHEN_USERNAME``` to determine if rspec is being run by kitchen or just by rspec.  If it is kitchen, then it will pass the ```--config-dir``` parameter to the salt-call commands to ensure the pillar data comes from the correct place (test-kitchen creates a pillar files from the data in .kitchen.yml and then tells the minion being run by test-kitchen where to find them via a custom minion config file).

Next, we'll need to change our tests to accept parameters.  This could be done in a number of ways, but my preference is to use [shared examples](https://relishapp.com/rspec/rspec-core/docs/example-groups/shared-examples).  In the 'state1' tests folder, there is a ```state1_shared.rb``` which defines the shared example for state1 and a ```linux_state1_custom_pillar.rb``` which gets its test from that file.  The shared example includes parameters which match up to the pillar data we could pass in.  The ```linux_state1_custom_pillar``` file then requires the shared file and includes the tests.  As part of the include, we pass the pillar data that was pulled via the ```get_pillar_data``` so the tests are run with our pillar values (or the defaults if no pillar data exists).

One thing to note: is that our pillar key names need to start with lower-case letters.  A variable name that starts with an upper-case letter in Ruby is a constant and can't be modified.  For this reason, all the pillar definable options in our defaults.yml must start with a lower-case letter so we can pass them through and modify the parameter to our shared example.


## Running serverspec tests through the salt-minion channel

It is possible to run serverspec tests through the salt-minion.  This can be accomplished by adding a salt backend to serverspec which uses the ruby salt-api interface.  I did this in a proof on concept type situation, but have not released or uploaded any of the code.

While this is great for not needing to authenticate to the system being tested (as that is done via salt), it adds a lot of overhead and slows the tests down considerably.

A set of tests that took about 3-5 minutes to run by SSH/WinRM took approximately 45 minutes to run through the salt-api.  This seems to be caused by the few seconds (if that) that are required to connect to the api, publish the job, the minion pick the job up, execute it, send a return to the master, and then the api client pick up the return and send the response back through serverspec.  When that process is repeated over hundreds of tests, it takes its toll.

That slow down is the main reason I haven't published any code related to it.  It wouldn't surprise me if there were some tweaks/etc that could be done to speed things up, but I'm not sure if the effort is worth it in the end.

If testing over the salt-minion channel is really desired or required, the [saltcheck module](https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.saltcheck.html)  may be the better solution for that.


