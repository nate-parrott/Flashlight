def results(fields, original_query):
	return {
		"title": "Toggle function keys",
		"run_args": [],
	}

def run():
	import sys, os
	directory = os.path.dirname(__file__)
	os.system("osascript {}/fntoggle.applescript".format(directory))