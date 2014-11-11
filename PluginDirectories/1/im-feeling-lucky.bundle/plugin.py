import urllib, json

def results(parsed, original_query):
	return {
		"title": "I'm feeling lucky '{0}'".format(parsed['~iflquery']),
		"run_args": ["http://www.google.com/search?&sourceid=navclient&btnI=I&q="+urllib.quote_plus(parsed['~iflquery'])]
	}

def run(url):
	import os
	os.system('open "{0}"'.format(url))
