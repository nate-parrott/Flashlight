def results(fields, original_query):
  import json
  js = fields['~js']
  settings = json.load(open('preferences.json'))
  html = open("js.html").read().replace("<!--JS-->", js).replace("<!--JSEVAL-->", js.replace('\\', '\\\\').replace('"','\\"')).replace("<!--THEME-->", settings['theme'])
  return {
    "title": "JS '{0}'".format(js),
    "run_args": [js],
    "html": html
  }

def run(js):
    import post_notification, pasteboard
    pasteboard.set_text(js)
    post_notification.post_notification("Javascript snippet copied to clipboard", "Flashlight JS")

if __name__=='__main__':
  run("/\d/.test(\"32\")")
