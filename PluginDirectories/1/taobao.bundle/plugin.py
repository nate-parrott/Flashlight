import urllib, json, i18n

def results(parsed, original_query):
    search_specs = [
        ["Taobao", "~taobaoquery", "http://s.m.taobao.com/h5?q=", "http://s.taobao.com/search?q="]
    ]
    for name, key, h5url, weburl in search_specs:
        if key in parsed:
            msg = parsed[key].encode('utf-8')
            search_url = i18n.localstr(h5url) + urllib.quote_plus(msg)
            web_url = i18n.localstr(weburl) + urllib.quote_plus(msg)
            return {
                "title": i18n.localstr("Search {0} for '{1}'").format(name, msg),
                "run_args": [web_url],
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
