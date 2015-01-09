#!/usr/bin/python

import sys, json, inspect, os
input = json.loads(sys.argv[1])
sys.path.insert(0, input['pluginPath'])
os.chdir(input['pluginPath'])
sys.path.append(input['builtinModulesPath'])
import plugin

class ParseTree(object):
	def __init__(self, json_dict):
		self.tag = json_dict['tag']
		self.contents = []
		for child in json_dict['contents']:
			if isinstance(child, dict):
				self.contents.append(ParseTree(child))
			else:
				self.contents.append(child)
	def multitags(self):
		# for compatibility w/ older plugins
		d = {}
		for child in self.contents:
			if isinstance(child, ParseTree):
				if child.tag not in d:
					d[child.tag] = []
				d[child.tag].append(child.text())
		return d
	def text(self):
		return u" ".join([(c.text() if isinstance(c, ParseTree) else c) for c in self.contents])
				

arguments = [input['args'], input['query']]
if len(inspect.getargspec(plugin.results)[0]) == 3:
	arguments.append(ParseTree(input['parseTree']))

results = plugin.results(*arguments)
if not results: quit()
if type(results) != list: results = [results]
print json.dumps(results)
