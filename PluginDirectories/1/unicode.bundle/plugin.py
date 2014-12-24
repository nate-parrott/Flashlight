#!/usr/bin/python

import i18n, os

def results(fields, original_query):
    query = fields['~query']
    title = i18n.localstr('Search Unicode characters for \'{0}\'').format(query)
    html = open(i18n.find_localized_path('unicode.html')).read().decode('utf-8').replace("%query%", query)
    return {
        "title": title,
        "html": html,
        "webview_transparent_background": True
    }
