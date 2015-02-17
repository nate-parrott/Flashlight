import os

def results(fields, original_query):
  js = fields['~js']
  html = open("node.html").read().replace("<!--JS-->", js)
  return {
    "title": "Node '{0}'".format(js),
    "run_args": [js],
	"html": html
  }

def run(js):
    from applescript import asrun, asquote
    from pipes import quote
    ascript = '''
    tell application "Terminal"
        activate
        do script {0}
    end tell
    '''.format(asquote('$(which node) -e "{0}" -p || echo "node.js is not installed."'.format(quote(js.encode('utf8')))))

    asrun(ascript)

if __name__=='__main__':
  run("3+2")
