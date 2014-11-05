#!/usr/bin/python
import json, os, sys, imp
from shared import plugin_dir, WorkingDirAs

if __name__=='__main__':
	plugin_name = sys.argv[1]
	print sys.argv[2]
	args = json.loads(sys.argv[2])
	plugin_path = os.path.join(plugin_dir, plugin_name+'.bundle', 'plugin.py')
	with WorkingDirAs(os.path.split(plugin_path)[0]):
		plugin_module = imp.load_source('plugin', plugin_path)
		results = plugin_module.run(*args)
