#!/usr/bin/python

import os
import commanding
from parse_example import parse_example_to_phrase
import sys
import json
import imp

example_phrases = []
plugin_dir = os.path.expanduser("~/Library/FlashlightPlugins")
for plugin in os.listdir(plugin_dir):
	if os.path.isdir(os.path.join(plugin_dir, plugin)):
		plugin_name, extension = os.path.splitext(plugin)
		if extension == '.bundle':
			examples_file = os.path.join(plugin_dir, plugin, "examples.txt")
			if os.path.exists(examples_file):
				for line in open(examples_file):
					line = line.strip()
					if len(line):
						example_phrases.append(parse_example_to_phrase(plugin_name, line))

def parse_query(query):
	parsed = commanding.parse_phrase(query, example_phrases)
	return {"plugin": parsed.intent, "arguments": parsed.tags()}

if __name__=='__main__':
	command = sys.argv[1]
	query = sys.argv[2]
	print query
	parsed = parse_query(query)
	plugin_path = os.path.join(plugin_dir, parsed['plugin']+'.bundle', 'plugin.py')
	plugin_module = imp.load_source('plugin', plugin_path)
	if sys.argv[1] == 'results':
		print json.dumps(plugin_module.results(parsed['arguments'], query))
	elif sys.argv[1] == 'run':
		plugin_module.run(parsed['arguments'], query, json.loads(sys.argv[3]))
