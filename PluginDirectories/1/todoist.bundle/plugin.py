def results(fields, original_query):
  task = fields['~task']
  import json
  settings = json.load(open("preferences.json"))
  token = settings.get('token')
  if token is None or token == '':
    return {
	    "title": "Todoist '{0}'".format(task),
	    "run_args": ['NO_CREDENTIALS'],
		"html": "<h1 style='font-family: sans-serif; padding: 2em'>Enter your Todoist API token in the plugin settings</h1>"
	}
  else:
    return {
	    "title": "Todoist '{0}'".format(task),
	    "run_args": [task],
		"html": "<h1 style='font-family: sans-serif; padding: 2em'>Create task: '{0}'</h1>".format(task)
	}

def run(task):
  if task != 'NO_CREDENTIALS':
    import json
    settings = json.load(open("preferences.json"))
    token = settings.get('token')
    import httplib, urllib2
    conn = httplib.HTTPSConnection("api.todoist.com")
    conn.request("POST", "/API/addItem?token=" + token + "&content=" + urllib2.quote(task.encode("utf8")))
    response = conn.getresponse()
    if response.status == 200:
      post_notification("Todoist task created successfully")
    else:
      post_notification("Task creation failed")

def post_notification(message, title="Flashlight"):
  import os, json, pipes
  # do string escaping:
  message = json.dumps(message)
  title = json.dumps(title)
  script = 'display notification {0} with title {1}'.format(message, title)
  os.system("osascript -e {0}".format(pipes.quote(script)))