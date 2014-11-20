import os
import urllib

def results(parsed, original_query):
    key=urllib.quote(parsed["~query"])
    url="http://devdocs.io/#q=" + key

    return {
        "title": "Search '{0}' on devdocs.io".format(key),
        "run_args": [url],
        "webview_links_open_in_browser": True
    }

def run(str):
    os.system('open "{0}"'.format(str))
