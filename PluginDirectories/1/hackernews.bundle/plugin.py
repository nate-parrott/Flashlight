def results(fields, original_query):
  message = fields['~message']
  return {
    "title": "Hacker News Search: {0}".format(message),
    "run_args": [message]
  }

def run(message):
  import webbrowser
  webbrowser.open("https://hn.algolia.com/?q={0}".format(message))

