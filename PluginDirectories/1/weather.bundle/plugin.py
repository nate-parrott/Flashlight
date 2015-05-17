#!/usr/bin/python

import urllib, os
import AppKit
import i18n


# Are you using the "dark" style in OS X?
# System Preferences > General > Use dark menu bar and Dock.
def dark_mode():
    import Foundation
    return Foundation.NSUserDefaults.standardUserDefaults().persistentDomainForName_(Foundation.NSGlobalDomain).objectForKey_("AppleInterfaceStyle") == "Dark"


# Is the computer locale metric or imperial?
def use_metric():
    import json
    settings = json.load(open('preferences.json'))
    if settings["units"] == "metric":
        return True
    elif settings["units"] == "imperial":
        return False
    else:
        return AppKit.NSLocale.currentLocale().objectForKey_(AppKit.NSLocaleUsesMetricSystem)


# Extract the country code from the location if given, or return local if not.
def get_country(location):
    country_codes = AppKit.NSLocale.ISOCountryCodes()
    current_country = AppKit.NSLocale.currentLocale().objectForKey_(AppKit.NSLocaleCountryCode)

    if ("," in location):
        for country in country_codes:
            if location.split(",")[1].strip().upper() == country:
                return country

    return current_country


def results(parsed, original_query):

    location = parsed['~location']
    country = get_country(location)
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
        .replace("<!--COUNTRY-->", country)
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
