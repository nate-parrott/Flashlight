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


# Adds the local country code to the city given if not specified
# By specified, we mean "london,CA" format.
def localise_location(location):
    country_codes = AppKit.NSLocale.ISOCountryCodes()
    current_country = AppKit.NSLocale.currentLocale().objectForKey_(AppKit.NSLocaleCountryCode)

    if ("," in location):
        if location.upper().endswith(tuple(country_codes)):
            return location
        else:  #Comma, but invalid country, so remove it
            location = location.split(",")[0]
    return location + "," + current_country


def results(parsed, original_query):

    location = parsed['~location']
    location = localise_location(location)
    if 'time/now' in parsed:
        time = 'now'
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
