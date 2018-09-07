# -*- coding: utf-8 -*-
import pytest
 
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
    assert pillarData == expectedValue
 
 
@pytest.mark.parametrize("minionid,grainUpdates",
        [
            # specify a minion ID and a dict of grains
            # ('a_minion_id', {'grain':'value'}),
        ])
def test_pillar_rendering(saltCaller, pytestconfig, minionid, grainUpdates):
    '''
    this function will test that the pillar renders without any errors
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
    assert '_errors' not in pillarData