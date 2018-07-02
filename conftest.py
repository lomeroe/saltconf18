# -*- coding: utf-8 -*-

import pytest

import re
import sys
import logging
import os
import shutil
import fnmatch

logging.basicConfig(stream=sys.stdout, level=logging.ERROR, format='STDOUT: %(message)s')

@pytest.fixture(scope="function")
def saltCaller(tmpdir):
    import salt.client
    import salt.config
    # we have a default copy of /etc/salt/minion
    # in the file jenkins_minion with r permissions
    # by the jenkins group
    os.makedirs(str(os.path.join(str(tmpdir), 'etc', 'salt')))
    shutil.copy2('pytest_minion', str(os.path.join(str(tmpdir), 'etc', 'salt', 'minion')))
    __opts__ = salt.config.minion_config(str(os.path.join(str(tmpdir), 'etc', 'salt', 'minion')))
    __opts__['conf_file'] = str(os.path.join(str(tmpdir), 'etc', 'salt', 'minion'))
    __opts__['config_dir'] = str(os.path.join(str(tmpdir), 'etc', 'salt'))
    __opts__['file_client'] = 'local'
    __opts__['cachedir'] = str(tmpdir)
    __opts__['utils_dirs'] = str(os.path.join(str(tmpdir), 'extmods', 'utils'))
    __opts__['extension_modules'] = str(os.path.join(str(tmpdir), 'extmods'))
    caller = salt.client.Caller(mopts=__opts__)
    return caller


@pytest.fixture(scope="function")
def saltRunner(tmpdir):
    import salt.config
    import salt.runner
    __opts__ = salt.config.master_config('/etc/salt/minion')
    __opts__['file_client'] = 'local'
    __opts__['cachedir'] = str(tmpdir)
    __opts__['utils_dirs'] = str(tmpdir.join('/extmods/utils'))
    __opts__['extension_modules'] = str(tmpdir.join('/extmods'))
    runner = salt.runner.RunnerClient(__opts__)
    return runner
