# -*- coding: utf-8 -*-
#!/usr/bin/python

import sys, os, re
import json

def results(parsed, original_query):
    number = parsed.get('number', '')
    number = re.sub(r'[^0-9]', '', number)
    html = open("haomatong.html").read().replace("<!--NUMBER-->", number)
    return {
        "title": u'号码通搜索 "%s" 结果' % (number.decode('utf-8')),
        "html": html,
        "webview_user_agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53",
        "webview_links_open_in_browser": True,
    }
