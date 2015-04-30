import urllib
import json


def results(parsed, original_query):
    url = 'http://www.wordreference.com/<LANG_FROM><LANG_TO>/<TEXT>'

    mode = parsed['~mode']
    lang_from = mode[0:2].encode('UTF-8')
    lang_to = mode[2:].encode('UTF-8')

    word = parsed['~word'].encode('UTF-8')

    url = url.replace('<LANG_FROM>', lang_from)
    url = url.replace('<LANG_TO>', lang_to)
    url = url.replace('<TEXT>', urllib.quote_plus(word))

    return {
        "title": "Translate '%s' from %s to %s" % (word, lang_from, lang_to),
        "run_args": [url],
        "html": "<script>window.location=%s</script>" % json.dumps(url),
        "webview_user_agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53",
        "webview_links_open_in_browser": True
    }


def run(url):
    import os
    os.system('open "{0}"'.format(url))

# EOF
