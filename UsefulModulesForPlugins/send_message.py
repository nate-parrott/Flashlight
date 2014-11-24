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
    buddy = None
    if normalize_phone(recipient):
      buddy = normalize_phone(recipient)
    else:
      address_book = contacts.address_book_to_list()
      result = contacts.find_contact(recipient, address_book, "phone")
      if result:
        buddy = result['phone'][0]
    if not buddy:
      asrun("display notification %s with title \"Flashlight\""%(asquote("Couldn't find iMessage contact for %s."%recipient)))
      return
    
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
    send_message("rebecca plattus", "message test", True)
