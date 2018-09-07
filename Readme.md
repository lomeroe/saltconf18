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