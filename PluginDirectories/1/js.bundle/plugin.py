def results(fields, original_query):
  js = fields['~js']
  html = open("node.html").read().replace("<!--JS-->", js)
  return {
    "title": "Node '{0}'".format(js),
    "run_args": [js],
	"html": html
  }

def run(js):
    return

