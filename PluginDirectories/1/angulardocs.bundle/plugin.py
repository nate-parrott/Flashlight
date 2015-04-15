import urllib
import json
import i18n


def results(parsed, original_query):

    angular_specs = [
        ["~query", "http://docs-angular.herokuapp.com/#/<query>"]
    ]
    for key, url in angular_specs:
        if key in parsed:
            search_query = parsed[key].encode('UTF-8')
            title = i18n.localstr("Search in Angular Docs for '{0}'").format(search_query)
            search_url = url.replace("<query>", urllib.quote(search_query))
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
