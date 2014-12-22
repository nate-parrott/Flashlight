# -*- coding: utf-8 -*-
#!/usr/bin/python

def results(fields, query):
    if '~ac' in fields:
        message = fields['~ac']
        site = 'AcFun'
        url = "http://www.acfun.tv/search/#query={0}".format(message)
    else:
        message = fields['~bili']
        site = 'Bilibili'
        url = "http://www.bilibili.com/search?keyword={0}".format(message)

    html = "<script>setTimeout(function() {window.location = '" + url + "'}, 500);</script>"

    return {"title": "Search {0} in {1}".format(message, site),
            "run_args": [url],
            "html": html}

def run(url):
    import os
    os.system('open "{0}"'.format(url))