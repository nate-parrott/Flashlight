import datetime
from centered_text import centered_text

def results(fields, original_query):
  # print fields['@date']
  d = None
  has_time = False
  if '@date' in fields:
    timestamp, resolution = fields['@date']
    has_time = resolution < 24 * 60 * 60
    d = datetime.datetime.fromtimestamp(timestamp)
  date = "<p><strong>{0}</strong></p>".format(d.strftime("%A, %B %d %Y"))
  time = "<p>{0}</p>".format(d.strftime("%I:%M %p")) if has_time else ""
  return {
    "title": original_query,
    "html": centered_text(date + time, "Press Enter to open in Calendar"),
    "webview_transparent_background": True,
    "run_args": [timestamp]
  }

def run(timestamp):
  from applescript import asrun
  if timestamp:
    script = """on epoch2datetime(epochseconds)
  set myshell1 to "date -r "
  set myshell2 to " \\"+%m/%d/%Y %H:%M\\""
  log (myshell1 & epochseconds & myshell2)
  set theDatetime to do shell script (myshell1 & epochseconds & myshell2)
  
  return date theDatetime
end epoch2datetime

set theTime to epoch2datetime("{0}")

tell application "Calendar"
  activate
  view calendar at theTime
end tell
""".format(int(timestamp))
    a = open("/Users/nateparrott/Desktop/script.txt", "w")
    a.write(script)
    a.close()
    asrun(script)
