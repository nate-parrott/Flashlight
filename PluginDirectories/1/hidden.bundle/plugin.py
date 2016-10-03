def results(fields, original_query):
	if original_query == 'hide':
		import os
		isShowAllFiles = 'YES' == os.popen("defaults read com.apple.finder AppleShowAllFiles").read().strip()
		showAllFiles = not isShowAllFiles
	else:
		showAllFiles = fields['~message'] != 'yes'
	return {
		"title": "Show hidden files" if showAllFiles else "Hide hidden files",
		"run_args": ["YES" if showAllFiles else "NO"]
		#"html": "<h1 style='font-family: sans-serif; padding: 2em'>{0}</h1>".format(message)
	}

def run(showAllFiles):
	import os
	cmd = showAllFiles
	os.system("osascript -e 'do shell script \"defaults write com.apple.finder AppleShowAllFiles " + cmd + "\"'")
	os.system("osascript -e 'tell app \"Finder\" to quit'")
	os.system("osascript -e 'tell app \"Finder\" to activate'")