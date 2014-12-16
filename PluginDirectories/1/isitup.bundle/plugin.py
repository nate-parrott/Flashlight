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
    location = parsed['~site']
    location = location.split('://')[-1] # strip protocol
    title = i18n.localstr("Is '{0}' up?").format(location)
    
    html = open(i18n.find_localized_path("wrapper.html")).read().replace("[PLACEHOLDER]", location).replace("light-mode", "dark-mode" if dark_mode() else "light-mode")
    return {
        "title": title,
        "html": html,
        "webview_transparent_background": True,
        "run_args": location
    }
