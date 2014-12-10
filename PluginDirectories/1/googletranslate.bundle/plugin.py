import urllib
import json


def results(parsed, original_query):
    url = 'https://translate.google.com/m/translate#<LANG_FROM>/<LANG_TO>/<TEXT>'

    lang_from = original_query[4:6].encode('UTF-8')
    lang_to = original_query[6:8].encode('UTF-8')

    text = parsed['~text']
    if text[0:4] == '%s%s' % (lang_from, lang_to):
        text = text[5:]

    url = url.replace('<LANG_FROM>', lang_from)
    url = url.replace('<LANG_TO>', lang_to)
    url = url.replace('<TEXT>', urllib.quote_plus(text))

    return {
        "title": "Translate '%s' from %s to %s" % (text, lang_from, lang_to),
        "run_args": [url],
        "html": "<script>window.location=%s</script>" % json.dumps(url),
        "webview_user_agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53",
        "webview_links_open_in_browser": True
    }


def run(url):
    import os
    os.system('open "{0}"'.format(url.replace('/m/translate', '/')))

# EOF
