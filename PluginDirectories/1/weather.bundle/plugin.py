#!/usr/bin/python

import sys, urllib, os
import AppKit

def use_metric():
	return AppKit.NSLocale.currentLocale().objectForKey_(AppKit.NSLocaleUsesMetricSystem)

def results(parsed, original_query):
	location = parsed['location']
	metric = use_metric()
	html = open("weather.html").read().replace("<!--LOCATION-->", location).replace("<!--UNITS-->", "metric" if use_metric() else "imperial")
	return {
		"title": '"{0}" weather'.format(location),
		"html": html,
		"run_args": location
	}

def run(location):
	os.system('open "http://openweathermap.org/find?q={0}"'.format(urllib.quote(location)))
