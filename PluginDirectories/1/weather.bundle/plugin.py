#!/usr/bin/python

import sys, urllib, os
import AppKit

def dark_mode():
	import Foundation
	return Foundation.NSUserDefaults.standardUserDefaults().persistentDomainForName_(Foundation.NSGlobalDomain).objectForKey_("AppleInterfaceStyle") == "Dark"

def use_metric():
	return AppKit.NSLocale.currentLocale().objectForKey_(AppKit.NSLocaleUsesMetricSystem)

def results(parsed, original_query):
	location = parsed['location']
	html = open("weather.html").read().replace("<!--LOCATION-->", location).replace("<!--UNITS-->", "metric" if use_metric() else "imperial").replace("<!--APPEARANCE-->", "dark" if dark_mode() else "light")
	return {
		"title": '"{0}" weather'.format(location),
		"html": html,
		"webview_transparent_background": True,
		"run_args": location
	}

def run(location):
	os.system('open "http://openweathermap.org/find?q={0}"'.format(urllib.quote(location)))
