import os

def run(cmd):
	os.system(cmd)

def results(parsed, original_query):
	if ("lock" == original_query):
		return {
			"title": "Lock",
			"run_args": ["/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"]
		}

	if ("restart" == original_query):
		return {
			"title": "Restart",
			"run_args": ["osascript -e 'tell app \"System Events\" to restart'"]
		}

	if ("sleep" == original_query):
		return {
			"title": "Sleep",
			"run_args": ["osascript -e 'tell app \"System Events\" to sleep'"]
		}

	if ("shutdown" == original_query):
		return {
			"title": "Shutdown",
			"run_args": ["osascript -e 'tell app \"System Events\" to shut down'"]
		}

	if ("logout" == original_query):
		return {
			"title": "Logout",
			"run_args": ["osascript -e 'tell app \"System Events\" to log out'"]
		}
