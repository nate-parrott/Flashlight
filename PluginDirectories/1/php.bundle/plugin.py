#!/usr/bin/python

import sys, urllib, os
import AppKit

def results(parsed, original_query):
    php_query = parsed['~php_query']
    html = open("php.html").read().replace("<!--QUERY-->", php_query)
    return {
        "title": 'Search PHP manual for "{0}"'.format(php_query),
        "html": html,
        "webview_transparent_background": False,
        "run_args": [php_query]
    }

def run(php_query):
    os.system('open "http://php.net/manual-lookup.php?pattern={0}"'.format(urllib.quote(php_query)))
