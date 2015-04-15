# -*- coding: utf-8 -*-

import sys, os, re
import urllib
import json
import i18n

def results(parsed, original_query):

    name = "weblio"
    if '~webliodict' in parsed:
        key = parsed['~webliodict']
    if '~lang' in parsed:
        lang = parsed['~lang'].encode('utf-8')
        if lang in ("ejje", "en", "eng", "english", "英語"):
            url = "http://ejje.weblio.jp/content/"
        elif lang in ("cjjc", "cn", "chinese", "中国語"):
            url = "http://cjjc.weblio.jp/content/"
        elif lang in ("kjjk", "kr", "korean", "韓国語"):
            url = "http://kjjk.weblio.jp/content/"
        elif lang in ("ruigo", "thesaurus", "類語"):
            url = "http://thesaurus.weblio.jp/content/"
        else:
            url = "http://www.weblio.jp/content/"          
    else:
        url = "http://www.weblio.jp/content/"       

    if '~webliodict' in parsed:
        localizedurl = i18n.localstr(url)
        search_url = localizedurl + urllib.quote_plus(key.encode('UTF-8'))
        title = i18n.localstr(
            "Search {0} for '{1}'").format(name, key.encode('UTF-8'))
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
