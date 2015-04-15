def results(fields, original_query):
  return {
    "title": "Empty Trash",
    "run_args": []
  }

def run():
  import os
  os.system('osascript -e \'tell app "Finder" to empty\'')
