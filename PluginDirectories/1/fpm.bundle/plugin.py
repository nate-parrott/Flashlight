def results(fields, original_query):
  id = fields['~id']
  parsed = id.split('/')
  html = open("js.html").read().replace("{USER}", parsed[0]).replace("{REPO}", parsed[1])
  return {
    "title": "Flashpm '{0}'".format(id),
    "run_args": [id],
    "html": html
  }

def run(id):
    import post_notification, pasteboard
    pasteboard.set_text(id)
    post_notification.post_notification("Javascript snippet copied to clipboard", "Flashlight JS")

if __name__=='__main__':
  run("/\d/.test(\"32\")")
