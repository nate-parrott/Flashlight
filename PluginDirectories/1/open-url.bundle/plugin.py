import urlparse
from centered_text import centered_text

def results(fields, original_query):
	url = (fields.get('~url') if fields else original_query).strip().encode('utf-8')
	if ' ' in url: return []
	parsed = urlparse.urlparse(url)
	if not parsed.scheme:
		url = 'http://' + url
		parsed = urlparse.urlparse(url)
	if not parsed or '.' not in parsed.netloc: return []
	url = urlparse.urlunparse(parsed)
	link = "<a href='{0}'>{0}</a>".format(url)
	return {
	"title": "{0} - open URL".format(parsed.netloc),
	"run_args": [url],
	"html": centered_text(link, hint_text="Press enter to launch a browser"),
	"webview_transparent_background": True,
	"dont_force_top_hit": (not fields)
	}

def run(message):
	import os, pipes
	os.system('open "{0}"'.format(pipes.quote(message.encode('utf8'))))

