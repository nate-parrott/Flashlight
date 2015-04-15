def results(fields, original_query):
	if '~query' not in fields: return None
	query = fields['~query']
	import urllib
	url = "http://flashlight.nateparrott.com/directory?"  + urllib.urlencode([("search", query.encode('utf-8')), ('browse', '1'), ('deep_links', '1')])
	import json
	html = u"""
			<script>
			setTimeout(function() {
					window.location = <!--URL-->;
			}, 500);
			</script>
			
			<style>
			html, body {
				margin: 0px;
				width: 100%;
				height: 100%;
				color: #333;
				font-family: "HelveticaNeue";
			}
			body > #centered {
				display: table;
				width: 100%;
				height: 100%
			}
			body > #centered > div {
				display: table-cell;
				vertical-align: middle;
				text-align: center;
				font-size: x-large;
				line-height: 1.1;
				padding: 30px;
			}
			</style>
			<body>
			<div id='centered'>
			<div>
				Searching plugins...
			</div>
			</div>
			</body>
			
			
			""".replace('<!--URL-->', json.dumps(url))
	return {
		"title": u"'{0}' Flashlight Plugins".format(query),
		"html": html,
		"run_args": ["flashlight://search?q=" + urllib.quote(query.encode('utf-8'))],
		"webview_links_open_in_browser": True
	}

def run(url):
	if url:
		import os, pipes
		os.system("open {0}".format(pipes.quote(url)))
