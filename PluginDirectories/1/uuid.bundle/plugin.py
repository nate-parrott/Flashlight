from AppKit import NSPasteboard, NSPasteboardTypeString
import uuid
	
def results(fields, original_query):
    x = uuid.uuid4()
    s = str(x)
    return {
        "title": "UUID",
        "run_args": [s],
	    "html": s
    }

def run(text):
	NSPasteboard.generalPasteboard().clearContents()
	NSPasteboard.generalPasteboard().setString_forType_(text, NSPasteboardTypeString)