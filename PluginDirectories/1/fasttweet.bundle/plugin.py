import urllib
import json
import i18n


def results(parsed, original_query):

    tweet_specs = [
        ["~message", "https://twitter.com/share?text="]
    ]
    for key, url in tweet_specs:
        if key in parsed:
            localizedurl = i18n.localstr(url)
            tweet_url = localizedurl + urllib.quote_plus(parsed[key].encode('UTF-8'))
            title = i18n.localstr(
                "Tweet message '{0}'").format(parsed[key].encode('UTF-8'))
            return {
                "title": title,
                "run_args": [tweet_url],
                "html": """
                <script>
                setTimeout(function() {
                    window.location = %s
                }, 500);
                </script>
                """ % (json.dumps(tweet_url)),
                "webview_user_agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53",
                "webview_links_open_in_browser": True
            }

def run(url):
    import os
    os.system('open "{0}"'.format(url))
