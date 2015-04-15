#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os, re, subprocess

def get_topic_item(items):
	return {
		"title": "Kill '{0}'".format(os.path.basename(items[2])),
		"run_args": [items[0]]
	}

def get_processes(theQuery):
	command = r"ps -A -o pid -o %%cpu -o comm | grep -i %s" % theQuery
	results = subprocess.check_output(command, shell=True).split('\n')[:-1]
	processes = []

	for result in results:
		items = re.split(r'\s+', result.strip())
		processes.append(get_topic_item(items))
	return processes

def results(fields, original_query):
	theQuery = fields['~process'] if fields else original_query
	return get_processes(theQuery)

def run(process):
	import os
	os.system('kill -9 %d' % int(process))