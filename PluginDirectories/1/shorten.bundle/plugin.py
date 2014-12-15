import urllib2
import json

def results(parsed, original_query):
    return {
        "title": "Shorten '{0}' (press enter)".format(parsed['~url']),
        "run_args": [parsed['~url']]
    }

def run(message):
    import os
    os.system('echo ' + shorten(message) + " | pbcopy && osascript -e 'display notification \"Short URL copied to clipboard.\" with title \"Flashlight\"'")

def shorten(url):
    post_url = 'https://www.googleapis.com/urlshortener/v1/url'
    postdata = {'longUrl':url}
    headers = {'Content-Type':'application/json'}
    req = urllib2.Request(
        post_url,
        json.dumps(postdata),
        headers
    )
    ret = urllib2.urlopen(req).read()
    return json.loads(ret)['id']