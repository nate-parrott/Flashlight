import json, urllib, os

def results(parsed, original_query):
	q = parsed['wa_query'] if 'wa_query' in parsed else parsed['~wa_query']
	url = "http://m.wolframalpha.com/input/?i={0}".format(urllib.quote_plus(q))
	html = """
	<script>
	setTimeout(function() {
		window.location = %s;
	}, 500); // throttle a little
	</script>
	""" % (json.dumps(url))
	return {
		"title": "Ask Wolfram|Alpha '{0}'".format(q),
		"html": html,
		"run_args": [q]
	}

def run(query):
	url = "http://wolframalpha.com/input/?i={0}".format(urllib.quote_plus(query))
	os.system("open {0}".format(json.dumps(url)))
