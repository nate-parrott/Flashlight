#!/usr/bin/python

import i18n, os

def results(fields, original_query):
    html = open(i18n.find_localized_path('unicode.html')).read().decode('utf-8')
    if("~emoji" in fields):
        query = fields['~emoji']
        html = html.replace("%query%", query).replace("%type%", "emojis")
        title = i18n.localstr('Search emojis for \'{0}\'').format(query)
    else:
        query = fields['~query']
        html = html.replace("%query%", query).replace("%type%", "characters")
        title = i18n.localstr('Search unicode characters for \'{0}\'').format(query)
    return {
        "title": title,
        "html": html,
        "webview_transparent_background": True,
				"run_args": [],
				"pass_result_of_output_function_as_first_run_arg": True
    }

def run(character):
	if character:
		import subprocess
		subprocess.call(['printf "'+character+'" | LANG=en_US.UTF-8  pbcopy && osascript -e \'display notification "Copied!" with title "Flashlight"\''], shell=True)