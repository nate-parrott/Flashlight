def results(fields, original_query):
  keyword = fields['~keyword']
  html = (
        open("show.html").read().decode('utf-8')
        .replace("<!--KEYWORD-->", keyword)
    )
  return {
    "title": "Gyazo Seach '{0}'".format(keyword.encode('utf-8')),
    "run_args": [keyword.encode('utf-8')],
	"html": html,
    "webview_links_open_in_browser": True
  }

def run(message):
  import os, pipes
  os.system('open "https://gyazo.com/search/{0}"'.format(message.encode('utf8')))
