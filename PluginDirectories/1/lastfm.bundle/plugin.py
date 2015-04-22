import urllib, json, i18n

def results(parsed, original_query):
    search_specs = [
        ["Last.fm", "~lastfmquery", "http://m.last.fm/music/"]
    ]
    for name, key, url in search_specs:
        if key in parsed:
            url = i18n.localstr(url)
            search_url = i18n.localstr(url) + urllib.quote_plus(parsed[key])
            return {
                "title": i18n.localstr("Search {0} for '{1}'").format(name, parsed[key]),
                "run_args": [search_url],
                "html": """
                <script>
                setTimeout(function() {
                    window.location = %s
                }, 500);
                </script>
                """%(json.dumps(search_url)),
                "webview_user_agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53",
                "webview_links_open_in_browser": True
            }

def run(url):
    import os
    os.system('open "{0}"'.format(url))