def results(fields, original_query):
	import json, urllib
	keywords = json.load(open('preferences.json'))['keywords']
	for keyword in keywords:
		for prefix in [w.lower() + u' ' for w in [keyword['keyword'], keyword['siteName']]]:
			if original_query.lower().startswith(prefix):
				query = original_query[len(prefix):]
				url = keyword['url'].replace('123456', urllib.quote(query.encode('utf-8'))).encode('utf-8')
				return {
					"webview_user_agent": "Mozilla/5.0 (compatible; MSIE 10.0; Windows Phone 8.0; Trident/6.0; IEMobile/10.0; ARM; Touch; NOKIA; Lumia 920)",
					"webview_links_open_in_browser": True,
					"html": "<script>setTimeout(function(){location = %s[0]}, 300)</script>"%json.dumps([url]),
					"run_args": [url],
					"title": u"Search {0}: {1}".format(keyword['siteName'], query)
				}
	

def run(url):
	import os, pipes
	os.system('open {0}'.format(pipes.quote(url.encode('utf8'))))
