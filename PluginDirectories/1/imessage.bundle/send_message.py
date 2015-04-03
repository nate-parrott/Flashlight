import urllib
import contacts
from applescript import asrun, asquote
import re

def normalize_phone(num):
	drop = ' -.'
	for c in drop:
		num = num.replace(c, '')
	if len(num) > 5 and re.match(r"^[0-9]+$", num):
		return num
	else:
		return None

def send_message(recipient, body, attach_selected_files):
		buddy = recipient
		
		set_selected_files = """
		tell application "Finder"
			set selectedFiles to selection
		end tell
		""" if attach_selected_files else "set selectedFiles to {}"
		
		script = """
		%s
		using terms from application "Messages"
			tell application "Messages"
				activate
				set targetService to 1st service whose service type = iMessage
				set targetBuddy to buddy %s of targetService
				send %s to targetBuddy
				repeat with theFile in selectedFiles
					send (theFile as alias) to targetBuddy
				end repeat
			end tell
		end using terms from
		
		"""%(set_selected_files, asquote(buddy), asquote(body))
		print script
		asrun(script)

if __name__ == '__main__':
		send_message("7185947958", "message test", True)
