import urllib, json


def results(parsed, original_query):
    search_specs = [
         ["Jisho", "~jishoquery", "http://beta.jisho.org/search/"]
    ]
    for name, key, url in search_specs:
        if key in parsed:
            search_url = url + urllib.quote_plus(parsed[key])
            return {
                "title": "Search {0} for '{1}'".format(name, parsed[key]),
                "run_args": [search_url],
                "html": """
                <script>
                setTimeout(function() {
                    window.location = %s
                }, 500);
                </script>
                """%(json.dumps(search_url)),
                "webview_links_open_in_browser": True
            }

def run(url):
    import os
    os.system('open "{0}"'.format(url))
