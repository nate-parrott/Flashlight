# -*- coding: utf-8 -*-
#!/usr/bin/python

import sys, os, re
import urllib2
import json
import urllib

latest_api_url = 'http://www.v2ex.com/api/topics/latest.json'

def get_response(url):
    headers = {'User-Agent':'Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US; rv:1.9.1.6)Gecko/20091201 Firefox/3.5.6'}
    req = urllib2.Request(url = url, headers = headers)
    response = urllib2.urlopen(req).read()
    return response

def get_topic_item(d):
    title = d['title']
    url = d['url']
    content = d['content_rendered']
    replies = str(d['replies'])
    time = str(d['created'])
    nodeName = d['node']['title']
    nodeUrl = d['node']['url']
    userName = d['member']['username']
    userAvater = 'http:' + d['member']['avatar_normal']
    html = open('temp.html')\
        .read()\
        .replace('<!--userName-->', userName)\
        .replace('<!--userAvater-->', userAvater)\
        .replace('<!--nodeUrl-->', nodeUrl)\
        .replace('<!--nodeName-->', nodeName)\
        .replace('<!--time-->', time)\
        .replace('<!--replies-->', replies)\
        .replace('<!--content-->', content)\
        .replace('<!--TITLE-->', title);
    return {
        'title':title + ' | ' + nodeName,
        'html': html, 
        "webview_user_agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53",
        'webview_links_open_in_browser': True,
        'run_args': [url]
    }

def get_latest():
    data = json.loads(get_response(latest_api_url))
    result = []

    for d in data:
        result.append(get_topic_item(d))

    return result


def results(parsed, original_query):
    return get_latest()

def run(url):
    if url:
        import os
        import webbrowser
        webbrowser.open_new_tab(url)