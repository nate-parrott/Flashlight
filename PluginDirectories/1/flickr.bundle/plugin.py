import urllib, json, i18n

def results(parsed, original_query):
    search_url = "https://m.flickr.com/#/search/advanced_QM_q_IS_" + urllib.quote_plus(parsed["~query"]) + "_AND_ss_IS_0_AND_mt_IS_all_AND_w_IS_all"
    
    return {
        "title": i18n.localstr("Searching '{0}' using Flickr").format(parsed["~query"]),
        "run_args": [search_url],
        "html": """
        <script>
        setTimeout(function() {
            window.location = %s
        }, 500);
        </script>
        """%(json.dumps(search_url)),
        "webview_user_agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53",
        "webview_links_open_in_browser": False
    }

def run(url):
    import os
    os.system('open "{0}"'.format(url))
