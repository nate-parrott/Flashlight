#!/usr/bin/python

import sys, urllib, os
import AppKit
import i18n


# Are you using the "dark" style in OS X?
# System Preferences > General > Use dark menu bar and Dock.
def dark_mode():
    import Foundation
    return Foundation.NSUserDefaults.standardUserDefaults().persistentDomainForName_(Foundation.NSGlobalDomain).objectForKey_("AppleInterfaceStyle") == "Dark"


# Is the computer locale metric or imperial?
def use_metric():
    return AppKit.NSLocale.currentLocale().objectForKey_(AppKit.NSLocaleUsesMetricSystem)


def results(parsed, original_query):

    location = parsed['~location']
    if '~now' in parsed:
        if parsed['~now'] == i18n.localstr('now'):
            time = 'now'
        else:
            time = 'later'
    else:
        time = 'later'

    # Used for debugging
    # print >> sys.stderr, 'Original query: ' + original_query
    # print >> sys.stderr, 'Interpreted the time as: ' + time
    # print >> sys.stderr, 'Interpreted the location as: ' + location

    # title = i18n.localstr('"{0}" weather').format(location)
    # html = (
    #     open(i18n.find_localized_path("weather.html")).read().decode('utf-8')
    #     .replace("<!--LOCATION-->", location)
    #     .replace("<!--UNITS-->", "metric" if use_metric() else "imperial")
    #     .replace("<!--APPEARANCE-->", "dark" if dark_mode() else "light")
    #     .replace("<!--TIME-->", time)
    # )

    title = i18n.localstr('"{0}" weather').format(location)
    html = (
        open("weather.html").read().decode('utf-8')
        .replace("<!--LOCATION-->", location)
        .replace("<!--UNITS-->", "metric" if use_metric() else "imperial")
        .replace("<!--APPEARANCE-->", "dark" if dark_mode() else "light")
        .replace("<!--TIME-->", time)
        .replace("\"<!--WEEKDAYS-->\"", i18n.localstr('[\'Sunday\', \'Monday\', \'Tuesday\', \'Wednesday\', \'Thursday\', \'Friday\', \'Saturday\']'))
        .replace("\"<!--NOW-->\"", i18n.localstr('[\'Now\', \'Today\']'))
        .replace("<!--LOCALE-->", i18n.localstr("locale"))
    )

    

    return {
        "title": title,
        "html": html,
        "webview_transparent_background": True,
        "run_args": [location]
    }


def run(location):
    os.system('open "http://openweathermap.org/find?q={0}"'.format(urllib.quote(location)))
