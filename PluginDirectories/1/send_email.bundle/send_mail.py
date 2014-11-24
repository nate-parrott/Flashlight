import urllib
import contacts
from applescript import asrun, asquote

def send_mail(recipients, subject, body, attach_selected_files):
    emails = []
    address_book = contacts.address_book_to_list()
    for recip in recipients:
        if '@' in recip:
            emails.append(recip)
        else:
            result = contacts.find_contact(recip, address_book, "email")
            if result: emails.append(result['email'][0])
    
    recipient_lines = []
    for email in emails:
        recipient_lines.append("make new to recipient with properties {address:%s}"%(asquote(email)))
    
    file_command = """repeat with aFile in selectedFiles
            make new attachment with properties {file name: (aFile as alias)} at after last paragraph of content
        end repeat""" if attach_selected_files else ""
    
    script = """
    tell application "Finder"
      set selectedFiles to selection
    end tell
    
    tell application "Mail"
      activate
      set mgMessage to make new outgoing message with properties {subject:%s, content:%s, visible:true}
      tell mgMessage
        %s
        %s
      end tell
    end tell
    """%(asquote(subject), asquote(body), "\n".join(recipient_lines), file_command)
    print script
    asrun(script)

if __name__ == '__main__':
    send_mail(["jessie"], "hello", "message", True)
