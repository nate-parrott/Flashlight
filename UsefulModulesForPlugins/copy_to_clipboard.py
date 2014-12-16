def copy_to_clipboard(text):
  from AppKit import NSPasteboard, NSArray
  pb = NSPasteboard.generalPasteboard()
  pb.clearContents()
  a = NSArray.arrayWithObject_(text)
  pb.writeObjects_(a)

def clipboard_text():
  from AppKit import NSPasteboard, NSStringPboardType
  pb = NSPasteboard.generalPasteboard()
  return pb.stringForType_(NSStringPboardType)
  
if __name__=='__main__':
  copy_to_clipboard("this is a test")
