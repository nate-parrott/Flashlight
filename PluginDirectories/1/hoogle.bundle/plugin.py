import urllib
import json


def results(fields, original_query):
    if "~hooglequery" in fields:
        query = fields["~hooglequery"]
        url = ("https://www.haskell.org/hoogle/?hoogle={0}"
               .format(urllib.quote_plus(query)))
        html = """<script>
        setTimeout(function() {window.location = %s;}, 500);
        </script>""" % json.dumps(url)
        ua = ("Mozilla/5.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) "
              "AppleWebKit/600.1.4 (KHTML, like Gecko) "
              "Version/8.0 Mobile/12A365 Safari/600.1.4")
        return {
            "title": "Search Hoogle for '{0}'".format(query),
            "run_args": [url],
            "html": html,
            "webview_user_agent": ua,
            "webview_links_open_in_browser": True
        }


def run(url):
    import os
    os.system('open "{0}"'.format(url))
