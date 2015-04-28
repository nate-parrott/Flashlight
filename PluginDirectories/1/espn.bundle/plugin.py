import urllib
import json
import i18n


def results(parsed, original_query):
    search_specs = [
        ["ESPN", "~sport", "http://espn.go.com/{0}/scoreboard"]
    ]
    for name, key, url in search_specs:
        if key in parsed:
            parsed[key] = parsed[key].lower()
            search_url = url.format(urllib.quote_plus(parsed[key].encode('UTF-8')))
            # search_url = search_url.lower()
            title = "Find {1} scores on '{0}'".format(name, parsed[key].encode('UTF-8'))
            return {
                "title": title,
                "run_args": [search_url],
                "html": """
                <script>
                setTimeout(function() {
                    window.location = %s
                }, 500);
                </script>
                """ % (json.dumps(search_url)),
                "webview_user_agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53",
                "webview_links_open_in_browser": True
            }


def run(url):
    import os
    os.system('open "{0}"'.format(url))
