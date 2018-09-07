# -*- coding: utf-8 -*-
import pytest
import salt.utils

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
    assert type(ret) in [dict, salt.utils.odict.OrderedDict]
