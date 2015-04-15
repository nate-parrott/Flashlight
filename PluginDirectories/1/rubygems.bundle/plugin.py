import urllib
import json
import i18n

def results(parsed, original_query):
    search_specs = [
        ["RubyGems", "~query", "https://rubygems.org/search?query="]
    ]
    for name, key, url in search_specs:
        if key in parsed:
            localizedurl = i18n.localstr(url)
            search_url = localizedurl + urllib.quote_plus(parsed[key].encode('UTF-8'))
            title = i18n.localstr(
                "Search {0} for '{1}'").format(name, parsed[key].encode('UTF-8'))
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
                    "webview_user_agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Safari/600.1.4",
                    "webview_links_open_in_browser": True
            }


def run(url):
    import os
    os.system('open "{0}"'.format(url))
