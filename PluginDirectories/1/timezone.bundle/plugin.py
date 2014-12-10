#!/usr/bin/python

import sys, urllib, os
import AppKit
import i18n

def dark_mode():
    import Foundation
    return Foundation.NSUserDefaults.standardUserDefaults().persistentDomainForName_(Foundation.NSGlobalDomain).objectForKey_("AppleInterfaceStyle") == "Dark"

def use_metric():
    return AppKit.NSLocale.currentLocale().objectForKey_(AppKit.NSLocaleUsesMetricSystem)

def results(parsed, original_query):
    location = parsed['~location']
    title = i18n.localstr("Time in '{0}'").format(location)
    
    html = open(i18n.find_localized_path("timezone.html")).read().replace("[PLACEHOLDER]", location).replace("light-mode", "dark-mode" if dark_mode() else "light-mode")
    return {
        "title": title,
        "html": html,
        "webview_transparent_background": True,
        "run_args": location
    }