import os
import urllib

def results(parsed, original_query):
    key="~query"

    if key in parsed:
        url="http://devdocs.io/#q=" + urllib.quote(parsed[key])
        return {
                "title": "Search '{0}' on devdocs.io".format(parsed[key]),
                "run_args": [url],
                "webview_links_open_in_browser": True
                }


def run(str):
    os.system('open "{0}"'.format(str))
