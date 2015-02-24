from centered_text import centered_text

def deriveddata():
	return {
		"title": "Delete Xcode Derived Data",
		"html": centered_text("Press enter to delete Xcode's derived data."),
		"webview_transparent_background": True,
		"run_args": ["rm -rf -r ~/Library/Developer/Xcode/DerivedData", "Deleted derived data!"]
	}

def iossim():
	return {
		"title": "Launch iOS Simulator",
		"run_args": ['open "/Applications/Xcode.app/Contents/Developer/Applications/iOS Simulator.app"']
	}
   
def nuke():
	return {
		"title": "Nuke Xcode and Derived Data",
		"run_args": ['killall Xcode; rm -rf -r ~/Library/Developer/Xcode/DerivedData; /Applications/Xcode.app/Contents/MacOS/Xcode', "KABOOM!"]
	}

def results(fields, original_query):
	if 'deriveddata' in fields:
		return deriveddata()
	elif 'nuke' in fields:
		return nuke()
	elif 'iossim' in fields:
		return iossim()

def run(command, notification=None):
	import os
	os.system(command)
	if notification:
		from post_notification import post_notification
		post_notification(notification)
