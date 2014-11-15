# -*- coding: utf-8 -*-
#!/usr/bin/python

import sys, os, re
import urllib2
import json
import urllib


def get_response(word):
    url = 'http://fanyi.youdao.com/openapi.do?keyfrom=spotlightplugin&key=1323324025&type=data&doctype=json&version=1.1&q=' + urllib.quote(word)
    response = urllib2.urlopen(url).read()
    return response

def get_error(error_code):
    if error_code == 20:
        return '要翻译的文本过长'
    elif error_code == 30:
        return '无法进行有效的翻译'
    elif error_code == 40:
        return '不支持的语言类型'
    elif error_code == 50:
        return '无效的key'
    else:
        return '无词典结果'

def results(parsed, original_query):
    word = parsed['~string']



    response = get_response(word)
    result = json.loads(response)

    error_code = result.get('errorCode',60)

    if error_code != 0 :
        return {
            'title': get_error(error_code),
            'html': get_error(error_code),
        }

    basic = result.get('basic',{})
    explains = basic.get('explains',[])
    basic_str = ''
    if len(explains) > 0:
        basic_str = u'<h3>基础词典</h3><ul><li>%s</li></ul>' % '</li><li>'.join(explains)


    webs = result.get('web',[])
    web = []
    web_str = ''
    for item in webs:
        value = u'；'.join(item.get('value'))
        web.append('%s <br> %s' % (item.get('key'),value))
    if len(web) > 0:
        web_str = u'<h3>网络释义</h3><ul><li>%s</li></ul>' % '</li><li>'.join(web)


    temp_file = open('temp.html')
    temp = temp_file.read().decode('utf-8')
    temp_file.close()

    html = temp % dict(word=word.decode('utf-8'), basic=basic_str, web=web_str)


    return {
        'title': '%s 的翻译 - 回车打开网页查看' % word,
        'html': html,
        'run_args': [word],
    }



def run(word):
    import os
    import webbrowser
    url = 'http://dict.youdao.com/search?q=%s' % urllib.quote(word.encode('utf-8'))
    webbrowser.open_new_tab(url)