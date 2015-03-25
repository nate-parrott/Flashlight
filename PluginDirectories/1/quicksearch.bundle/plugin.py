import json

def run(info):
	query, completed_query = json.loads(info)
	q = completed_query if completed_query else query
	import os, pipes, urllib
	url = u"https://bing.com/search?" + urllib.urlencode([('q', q)])
	os.system('open {0}'.format(pipes.quote(url.encode('utf8'))))
