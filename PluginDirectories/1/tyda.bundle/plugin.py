from __future__ import unicode_literals
import json
import urllib

def results(fields, original_query):
	search_word = fields['~tyda']
	quoted_url = urllib.quote_plus(search_word.encode('utf-8'))
	base_url = "http://tyda.se/search/"
	search_url = base_url + quoted_url
	return {
	    "title": "Search Tyda.se for '{0}'".format(search_word),
	    "run_args": [search_url]
	}

def run(url):
	import os, pipes
	os.system('open "{0}"'.format(url))

