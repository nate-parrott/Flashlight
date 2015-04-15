# -*- coding: utf-8 -*-
#!/usr/bin/python
import urllib2

def getCubeUrl(symbol):
    return 'http://xueqiu.com/p/ZH%06d' % (int(symbol))
    
def getPageUrl(path):
    return 'http://xueqiu.com/%s' % (str(path))
    
    
def results(fields, original_query):
    import re
    url = ""
    if re.match(r'^zh.*', original_query, re.IGNORECASE):
        url = getCubeUrl(fields['~symbol'])
    elif re.match(r'^xq.*', original_query, re.IGNORECASE):
        url = getPageUrl(fields['~path'])
        
    file = open ('content.html')
    html = file.read().replace('url', url)
    file.close()
    return {
        "title": "雪球",
        "html": html,
        "webview_user_agent":"User-Agent:iPhone"
    }
    
