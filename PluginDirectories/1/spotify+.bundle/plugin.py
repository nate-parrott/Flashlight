import time
import json

# toolkit - dark/light mode
def theme():
	import Foundation
	dark_mode = Foundation.NSUserDefaults.standardUserDefaults().persistentDomainForName_(Foundation.NSGlobalDomain).objectForKey_("AppleInterfaceStyle") == "Dark"
	return "dark" if dark_mode else "light"

def play(qType, trackId):
	import os, json, pipes

	script = '''
	tell application "Spotify"
		play track "{0}"
	end tell
	'''.format(trackId)

	os.system("osascript -e {0}".format(pipes.quote(script)))

# album info view
def results(fields, original_query):

	searchQ = fields['~q']
	searchT = fields['~t']

	# build html from template
	pageSetup = (
		open("views/index.html").read().decode('utf-8')
		.replace("<!--THEME-->", theme())
		.replace("<!--QUERY-->", searchQ)
		.replace("<!--TYPE-->", searchT)
	)

	return {
		"title": "Searching for '{0}'".format(searchQ),
		"html" : pageSetup,
		"pass_result_of_output_function_as_first_run_arg": True,
		"run_args": [searchT],
		"webview_transparent_background": True
	}

def run(queryId, qType):
	play("track", queryId)
