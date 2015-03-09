#!/usr/bin/python

import sys, urllib, os
import AppKit

def results(parsed, original_query):

    query = parsed['~query']

    html = (
        open("index.html").read().decode('utf-8')
        .replace("<!--QUERY-->", query)
    )

    return {
        "title": '',
        "html": html,
        "webview_transparent_background": True,
        "run_args": [query]
    }


def run(query):
    print 'run'