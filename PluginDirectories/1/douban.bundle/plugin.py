# -*- coding: utf-8 -*-
#!/usr/bin/python

import sys, os, re
import urllib

def results(parsed, original_query):
    keyword = parsed.get('~keyword', '').strip()
    html = open("douban.html").read().replace("<!--KEYWORD-->", keyword)
    return {
        "title": u'豆瓣搜索 "{}" 结果'.format(keyword),
        "html": html,
        "run_args": [keyword],
        "webview_user_agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53",
        "webview_links_open_in_browser": True,
    }

def run(keyword):
    if keyword:
        os.system('open "http://movie.douban.com/subject_search?search_text={0}"'.format(urllib.quote(keyword.encode('utf-8'))))
