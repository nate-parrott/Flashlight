import os, centered_text

def is_cloudapp_installed():
	bundle = "com.linebreak.CloudAppMacOSX"
	from AppKit import NSWorkspace
	return NSWorkspace.sharedWorkspace().absolutePathForAppBundleWithIdentifier_(bundle) != None

def results(fields, original_query):
	paths = [fields['@file']['path']] + fields['@file']['otherPaths']
	files = [path for path in paths if path and not os.path.isdir(path)]
	if is_cloudapp_installed():
		if len(files):
			_, name = os.path.split(files[0])
			return {
				"title": u"Upload '{0}' to CloudApp".format(name),
				"run_args": [files[0]],
				"webview_transparent_background": True,
				"html": centered_text.centered_text(u"Upload <strong>'{0}'</strong> with CloudApp".format(name))
			}
		else:
			return {
				"title": "Upload to CloudApp",
				"webview_transparent_background": True,
				"html": centered_text.centered_text("Pick a file.")
			}
	else:
		return {
			"title": "Upload to CloudApp",
			"html": centered_text.centered_text("<a href='http://getcloudapp.com'>Install CloudApp</a> to share this file."),
			"webview_transparent_background": True,
			"webview_links_open_in_browser": True
		}

def run(file):
	from applescript import asrun, asquote
	asrun("""
	tell application "CloudApp"
		upload POSIX file {0}
	end tell
	""".format(asquote(file)))

