#coding:utf-8

def results(fields, original_query):
  if("~chinese" in fields):
    message = fields['~chinese']
    title = '中文转unicode'
    html = message.encode('unicode_escape')
    data = html
  else:
    message = fields['~unicode']
    title = 'unicode转中文'
    html = message.decode('unicode_escape')
    data = html
  return {
    "title": title,
    "run_args": [data],
    "html": html
  }

def run(message):
  import subprocess
  subprocess.call(['printf "' + message + '" | LANG=en_US.UTF-8 pbcopy && osascript -e \'display notification "Copied!" with title "Flashlight"\''], shell=True)
