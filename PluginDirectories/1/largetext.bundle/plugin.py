
def results(parsed, query):
  from centered_text import centered_text
  return {
    "title": "Large Text",
    "html": centered_text(parsed['~text'], hint_text="Press enter to show full-screen"),
    "webview_transparent_background": True,
    "run_args": [parsed['~text']]
  }

def run(text):
  import subprocess, sys
  pid = subprocess.Popen([sys.executable, "large_text.py", text], stdout=subprocess.PIPE, stderr=subprocess.PIPE, stdin=subprocess.PIPE)
