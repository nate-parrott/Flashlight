import json, urllib, os

def results(parsed, original_query):
	url = "http://m.wolframalpha.com/input/?i={0}".format(urllib.quote_plus(parsed['wa_query']))
	html = """
	<script>
	window.location = {0};
	</script>
	""".format(json.dumps(url))
	return {
		"title": "Ask Wolfram|Alpha '{0}'".format(parsed['wa_query']),
		"html": html,
		"run_args": [parsed['wa_query']]
	}

def run(query):
	url = "http://wolframalpha.com/input/?i={0}".format(urllib.quote_plus(query))
	os.system("open {0}".format(json.dumps(url)))
