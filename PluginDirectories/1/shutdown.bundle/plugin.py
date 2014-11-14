import os

def run(cmd):
	os.system(cmd)

def results(parsed, original_query):
	if ("lock_command" in parsed):
		return {
			"title": "Lock Mac",
			"run_args": ["/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"]
		}

	if ('restart_command' in parsed):
		return {
			"title": "Restart Mac",
			"run_args": ["osascript -e 'tell app \"System Events\" to restart'"]
		}

	if ('sleep_command' in parsed):
		return {
			"title": "Put Mac to sleep",
			"run_args": ["osascript -e 'tell app \"System Events\" to sleep'"]
		}

	if ('shutdown_command' in parsed):
		return {
			"title": "Shut down Mac",
			"run_args": ["osascript -e 'tell app \"System Events\" to shut down'"]
		}

	if ('logout_command' in parsed):
		return {
			"title": "Log out",
			"run_args": ["osascript -e 'tell app \"System Events\" to log out'"]
		}

	if ('empty_trash_command' in parsed):
		return {
			"title": "Empty the Trash",
			"run_args": ["osascript -e 'tell app \"Finder\" to empty the trash'"]
		}
