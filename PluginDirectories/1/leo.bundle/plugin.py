import urllib
import json
import i18n
import json

def results(parsed, original_query):
    url = 'http://pda.leo.org/<LANG>de/index_de.html#/search=<TEXT>&searchLoc=0&resultOrder=basic&multiwordShowSingle=on'
    langs = ['en ', 'fr ', 'es ', 'it ', 'ch ', 'ru ', 'pt ', 'pl ']
    text = parsed['~text'].encode('UTF-8')

    if text[0:3] in langs:
        lang = text[0:2]
        text = text[3:]
    else:
        lang = json.load(open('preferences.json'))['lang']

    url = url.replace('<LANG>', lang)
    url = url.replace('<TEXT>', urllib.quote(text))

    return {
        "title": i18n.localstr("Look up '{0}' at Leo.org").format(text.decode('UTF-8')),
        "run_args": [url],
        "html": "<script>setTimeout(function() {window.location = %s;}, 500);</script>" % json.dumps(url),
        "webview_links_open_in_browser": True
    }


def run(url):
    import os
    os.system('open "{0}"'.format(url))

# EOF
