#!/usr/bin/python

import i18n, os

def results(fields, original_query):
    html = open(i18n.find_localized_path('unicode.html')).read().decode('utf-8')
    if("~emoji" in fields):
        query = fields['~emoji']
        html = html.replace("%query%", query).replace("%type%", "emoji")
    else:
        query = fields['~query']
        html = html.replace("%query%", query).replace("%type%", "characters")
    title = i18n.localstr('Search emoji for \'{0}\'').format(query)
    return {
        "title": title,
        "html": html,
        "webview_transparent_background": True
    }
