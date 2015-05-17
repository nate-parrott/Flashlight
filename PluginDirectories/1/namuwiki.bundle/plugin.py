#encoding=utf-8
import urllib
import json
import i18n
import unicodedata


def results(parsed, original_query):
    name = "Namu Wiki"
    key = '~namuquery'
    url = 'https://namu.wiki/w/'

    if key not in parsed:
        return

    # Managing hangul. 'ㅎㅏㄴㄱㅡㄹ' -> '한글'
    query = unicodedata.normalize('NFC', parsed[key])

    search_url = i18n.localstr(url) + urllib.quote(query.encode('utf-8'))
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
        "webview_user_agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53",
        "webview_links_open_in_browser": True
    }


def run(url):
    import os
    os.system('open "%s"' % url)
