
def get_text():
	from AppKit import NSPasteboard, NSPasteboardTypeString
	return NSPasteboard.generalPasteboard().stringForType_(NSPasteboardTypeString)

def set_text(text):
	from AppKit import NSPasteboard, NSPasteboardTypeString
	NSPasteboard.generalPasteboard().clearContents()
	NSPasteboard.generalPasteboard().setString_forType_(text, NSPasteboardTypeString)

