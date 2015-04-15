import subprocess, os

def icons_visible():
	return subprocess.check_output("defaults read com.apple.finder CreateDesktop", shell=True).strip() == 'true'

def set_icons_visible(visible):
	os.system("defaults write com.apple.finder CreateDesktop {0} && killall Finder".format('true' if visible else 'false'))

def results(fields, original_query):
	from centered_text import centered_text
	
	visible = 'show' in fields
	description = 'visible' if visible else 'hidden'
	if visible == icons_visible():
		return None
	else:
		text = "Show desktop icons" if visible else "Hide desktop icons"
		return {
			"title": text,
			"run_args": [visible],
			"html": centered_text(text, "PRESS ENTER"),
			"webview_transparent_background": True
		}

def run(visible):
	set_icons_visible(visible)
