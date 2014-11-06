#!/usr/bin/python
import json, os, sys, imp
from shared import plugin_dir, WorkingDirAs

if __name__=='__main__':
	plugin_name = sys.argv[1]
	args = json.loads(sys.argv[2])
	plugin_path = os.path.join(plugin_dir, plugin_name+'.bundle', 'plugin.py')
	print plugin_path
	with WorkingDirAs(os.path.split(plugin_path)[0]):
		plugin_module = imp.load_source(plugin_name, plugin_path)
		results = plugin_module.run(*args)
