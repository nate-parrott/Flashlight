import urllib

def results(fields, original_query):
    words = fields['~words'].encode('UTF-8')
    words_escaped = urllib.quote_plus(words)

    url = "http://www.multitran.ru/c/m.exe?CL=1&l1=1&s=" + words_escaped
    html = open("content.html").read().replace("#words#", words_escaped)
    return {
        "title": "Translation for %s" % (words),
        "run_args": [url],
        "html": html,
        "webview_user_agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53",
        "webview_links_open_in_browser": True,
        "webview_transparent_background": True
   }


def run(url):
    import os
    os.system('open "{0}"'.format(url))
