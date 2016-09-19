import pasteboard

def results(fields, original_query):
  text = fields.get('~text')
  if not text:
	  text = pasteboard.get_text()
  if not text:
	  text = "Your text here"
  return {
	"title": "Word Count",
    "webview_transparent_background": True,
	"html": open("widget.html").read().replace("<!--TEXT-->", text.encode('utf-8'))
  }
