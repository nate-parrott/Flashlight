#!/usr/bin/python

import sys, json, os
input = json.loads(sys.argv[1])
os.chdir(input['pluginPath'])
sys.path.insert(0, input['pluginPath'])
sys.path.append(input['builtinModulesPath'])
import plugin
plugin.run(*input['runArgs'])
