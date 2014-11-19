#!/usr/bin/python

import sys, urllib, os
import AppKit

def dark_mode():
    import Foundation
    return Foundation.NSUserDefaults.standardUserDefaults().persistentDomainForName_(Foundation.NSGlobalDomain).objectForKey_("AppleInterfaceStyle") == "Dark"

def use_metric():
    return AppKit.NSLocale.currentLocale().objectForKey_(AppKit.NSLocaleUsesMetricSystem)

def results(parsed, original_query):
    location = parsed['~location']
    html = open("timezone.html").read().replace("[PLACEHOLDER]", location)
    return {
        "title": 'Time in "{0}"'.format(location),
        "html": html,
        "webview_transparent_background": True,
        "run_args": location
    }

def run(location):
    os.system('open "http://openweathermap.org/find?q={0}"'.format(urllib.quote(location)))
