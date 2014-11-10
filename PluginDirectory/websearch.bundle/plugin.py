import urllib

def results(parsed, original_query):
	search_specs = [
		 ["Google", "~googlequery", "https://www.google.com/search?q="],
		 ["Duck Duck Go", "~duckduckgoquery", "https://duckduckgo.com/?q="],
		 ["Google Images", "~googleimagequery", "https://www.google.com/search?tbm=isch&q="]
	]
	for name, key, url in search_specs:
		if key in parsed:
			return {
				"title": "Search {0} for '{1}'".format(name, parsed[key]),
				"run_args": [url + urllib.quote_plus(parsed[key])]
			}

def run(url):
	import os
	os.system('open "{0}"'.format(url))
