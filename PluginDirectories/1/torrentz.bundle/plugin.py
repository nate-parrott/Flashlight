import urllib2, urllib, time, json
def results(fields, original_query):
    time.sleep(0.2)
    message = fields['~message']
    req = urllib2.Request('http://torrentz.eu/suggestions.php?q={0}'.format(urllib.quote_plus(message)))
    response = urllib2.urlopen(req)
    the_page = response.read()
    result = json.loads(the_page)
    l = ""
    for x in result[1]:
    	l += '<li><a href="http://torrentz.eu/search?f={0}">{1}</a></li>'.format(x, x)
    tmpl = open('template.html')
    html = tmpl.read().replace('##LISTITEMS##', l)
    return {
        "title": "BlaBlaBla '{0}'".format(message),
        "run_args": [message], # ignore for now
        "webview_links_open_in_browser": True,
        "html": html
    }