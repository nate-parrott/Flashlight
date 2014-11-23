# -*- coding: utf-8 -*-
#!/usr/bin/python

import sys, os, re
import urllib2
import json
import urllib


def get_response(url):
    headers = {'User-Agent':'Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US; rv:1.9.1.6)Gecko/20091201 Firefox/3.5.6'}
    req = urllib2.Request(url = url, headers = headers)
    response = urllib2.urlopen(req).read()
    return response

def get_daily_item(d):
    title = d['title']
    url = d['share_url']
    html = open('temp.html').read().replace('<!--TITLE-->', title)
    return {
        'title':title,
        'html': html, 
        "webview_user_agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53",
        'webview_links_open_in_browser': True,
        'run_args': [url]
    }

def get_daily():
    data = json.loads(get_response('http://news-at.zhihu.com/api/3/news/latest'))
    result = []
    topStories = data['top_stories']
    stories = data['stories']

    for d in topStories:
        result.append(get_daily_item(d))

    for d in stories:
        result.append(get_daily_item(d))

    return result

def get_hot_item(d):
    _id = d['news_id']
    title = d['title']
    url = 'http://daily.zhihu.com/story/' + str(_id)
    html = open('temp.html').read().replace('<!--TITLE-->', title)
    return {
        'title':title,
        'html': html, 
        "webview_user_agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53",
        'webview_links_open_in_browser': True,
        'run_args': [url]
    }

def get_hot():
    data = json.loads(get_response('http://news-at.zhihu.com/api/3/news/hot'))
    recent = data['recent']
    result = []
    for d in recent:
        result.append(get_hot_item(d))
    return result

def results(parsed, original_query):
    if original_query == 'zhihu daily':
        return get_daily()
    else:
        return get_hot()

def run(url):
    if url:
        import os
        import webbrowser
        webbrowser.open_new_tab(url)