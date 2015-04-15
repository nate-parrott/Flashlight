import urllib, json, i18n
from centered_text import centered_text

def results(parsed, original_query):
		settings = json.load(open('preferences.json'))
		shortcuts = settings["shortcuts"]
		count = len(shortcuts)
		for i in range(count): 
				url = shortcuts[i]["url"]
				shortcut = shortcuts[i]["shortcut"]
				if shortcut.lower() == original_query.lower():
						if url.startswith('http') == False: 
								if not '//' in url: 
										url = "http://" + url
						link = "<a href='{0}'>{0}</a>".format(url)
						return {
						"title": u"Open " + url,
						"run_args": [url],
						"html": centered_text(link, hint_text="Press enter to launch a browser"),
						"webview_transparent_background": True,
						}

def run(url):
		import os
		os.system('open "{0}"'.format(url))
