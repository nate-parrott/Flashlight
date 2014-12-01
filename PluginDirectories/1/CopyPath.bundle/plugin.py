import os, i18n

def results(parsed, original_query):
    return {
        "title": i18n.localstr('Copy Path'),
            "run_args": ['']
    }

def run(command):
	from applescript import asrun, asquote
	# TODO: set the current working dir to the frontmost dir in Finder
	ascript = '''
	tell application "Finder"
		set theItems to selection
		set filePath to (POSIX path of (the selection as alias))
	end tell
	set the clipboard to filePath
	'''.format(asquote(command))

	asrun(ascript)
