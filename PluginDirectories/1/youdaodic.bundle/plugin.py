# -*- coding: utf-8 -*-
#!/usr/bin/python

import sys, os, re
import urllib2
import json
import urllib

def run(word):
    import os
    import webbrowser
    url = 'http://dict.youdao.com/search?q=%s' % urllib.quote(word.encode('utf-8'))
    webbrowser.open_new_tab(url)


def results(parsed, original_query):
    word = parsed['~string']
    html = open("youdao.html").read().decode('utf-8').replace("<!--WORD-->", word)
    return {
        'title': u'%s 的翻译 - 回车打开网页查看' % word.decode('utf-8'),
        "html": html,
        'run_args': [word],
        "webview_user_agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53",
        "webview_links_open_in_browser": True,
    }
