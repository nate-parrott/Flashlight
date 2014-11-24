# -*- coding: utf-8 -*-
#!/usr/bin/python

import sys, os, re
import urllib
import json
import random

def results(parsed, original_query):
    number = parsed.get('number', '')
    number = re.sub(r'[^0-9]', '', number)
    html = open("kuaidi.html").read().replace("<!--NUMBER-->", number)
    return {
        "title": u'快递 100 搜索 "%s" 结果' % number,
        "html": html,
        "run_args": [number],
        "webview_user_agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53",
        "webview_links_open_in_browser": True,
    }

def run(number):
    if number:
        os.system('open "http://m.kuaidi100.com/result.jsp?nu={0}"'.format(urllib.quote(number)))
