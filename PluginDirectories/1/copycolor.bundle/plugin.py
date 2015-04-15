import os

def is_color(c):
	import re
	return re.match("^#([a-fA-F0-9]{3}|[a-fA-F0-9]{6})$", c) != None

def find_format(parsed):
		for field in parsed:
				if field.startswith('format/'):
						return field[len('format/'):]
		return 'hex'

def results(parsed, query):
		if 'color' in parsed:
				if is_color(parsed['color']):
						return {
							"title": "Preview color {0}".format(parsed['color']),
							"html": "<body style='background-color: %s'></body>"%parsed['color']
						}
				else:
						return None
		else:
				format = find_format(parsed)
				format_for_display = {
					"uicolor_swift": "UIColor for Swift",
					"uicolor": "UIColor for Objective-C"
				}.get(format, format)
				return {
				"title": "Pick a color as {0}".format(format_for_display),
				"run_args": [format]
				}

def run(format):
	import subprocess, sys
	pid = subprocess.Popen([sys.executable, "pick_color.py", format], stdout=subprocess.PIPE, stderr=subprocess.PIPE, stdin=subprocess.PIPE)
