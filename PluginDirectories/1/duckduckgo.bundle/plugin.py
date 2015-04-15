import i18n
import json
import urllib


def results(parsed, original_query):

    search_specs = [
        ["Duck Duck Go", "~duckduckgoquery", "https://duckduckgo.com/?q="]
    ]
    user_agent = ("Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) " +
                  "AppleWebKit/537.51.1 (KHTML, like Gecko) " +
                  "Version/7.0 Mobile/11A465 Safari/9537.53")
    for name, key, url in search_specs:
        if key in parsed:
            search_item = parsed[key].encode('utf_8')
            localizedurl = i18n.localstr(url)
            search_url = localizedurl + urllib.quote_plus(search_item)
            title = i18n.localstr("Search {0} for '{1}'").format(name,
                                                                 search_item)

            return {
                "title": title,
                "run_args": [search_url],
                "html": """<script>
                        setTimeout(function() {
                            window.location = %s
                        }, 500);
                        </script>""" % (json.dumps(search_url)),
                "webview_user_agent": user_agent,
                "webview_links_open_in_browser": True
            }


def run(url):
    import os
    os.system('open "{0}"'.format(url))
