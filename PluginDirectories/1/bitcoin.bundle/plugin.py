# -*- coding: utf-8 -*-
#!/usr/bin/python

import sys, os, re
import urllib2
import json
import urllib
import AppKit

cny_api_url = 'https://www.okcoin.cn/api/ticker.do'
usd_api_url = 'https://www.okcoin.com/api/ticker.do?ok=1'

def get_response(url):
    headers = {'User-Agent':'Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US; rv:1.9.1.6)Gecko/20091201 Firefox/3.5.6'}
    req = urllib2.Request(url = url, headers = headers)
    response = urllib2.urlopen(req).read()
    return response

"""def get_cny_price():
    data = json.loads(get_response(cny_api_url))
    return data['ticker']['last']

def get_usd_price():
    data = json.loads(get_response(usd_api_url))
    return data['ticker']['last']
"""
def use_cny():
    return AppKit.NSLocale.currentLocale().objectForKey_(AppKit.NSLocaleCurrencyCode) == 'CNY'
    

def results(parsed, original_query):
    count = str(1)
    if'~n' in parsed.keys():
        count = parsed['~n']
    price = 0
    symbol = '¥' if use_cny() else '$'
    url = cny_api_url if use_cny() else usd_api_url
    money = float(count) * float(price)
    html = (open('temp.html').read()
        .replace('<!--url-->', url)
        .replace('<!--count-->', count)
        .replace('<!--symbol-->', symbol))
    return {
        'title': ("Bitcoin price" if count=="1" else "Price of {0} bitcoins".format(count)),
        'html': html
    }
