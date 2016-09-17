def results(fields, original_query):
  html=""
  if("~chr" in fields):
    message = fields['~chr']
    title = "char of "+message
    for tmp in message.split():
        html=html+" "+chr(int(tmp))
    data = html.lstrip()
  else:
    message = fields['~asc']
    title = "ascii of "+message
    for tmp in message.split():
        html=html+" "+str(ord(tmp))
    data = html.lstrip()
  return {
    "title": title,
    "run_args": [data],
    "html": html
  }

def run(message):
  import subprocess
  subprocess.call(['printf "' + message + '" | LANG=en_US.UTF-8 pbcopy && osascript -e \'display notification "Copied!" with title "Flashlight"\''], shell=True)
