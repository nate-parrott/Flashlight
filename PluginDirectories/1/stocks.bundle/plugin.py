import urllib, json

def results(parsed, original_query):
    url = "http://finance.yahoo.com/q?s="
    search_url = url + urllib.quote_plus(parsed['~stockquery'])
    return {
        "title": "Stock {0} data".format(parsed['~stockquery']),
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
