#!/usr/bin/python

import sys, urllib, os

def results(parsed, original_query):
	location = parsed['location']
	html = open("weather.html").read().replace("<!--LOCATION-->", location)
	return {
		"title": '"{0}" weather'.format(location),
		"html": html,
		"run_args": location
	}

def run(location):
	os.system('open "http://openweathermap.org/find?q={0}"'.format(urllib.quote(location)))
