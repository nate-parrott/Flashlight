def results(fields, original_query):
  task = fields['~task']
  import json
  settings = json.load(open("preferences.json"))
  email = settings.get('email')
  password = settings.get('password')
  if email is None or password is None or email == '' or password == '':
    return {
	    "title": "Wunderlist '{0}'".format(task),
	    "run_args": ['NO_CREDENTIALS'],
		"html": "<h1 style='font-family: sans-serif; padding: 2em'>Enter your Wunderlist credentials in the plugin settings</h1>"
	}
  else:
    return {
	    "title": "Wunderlist '{0}'".format(task),
	    "run_args": [task],
		"html": "<h1 style='font-family: sans-serif; padding: 2em'>Create task: '{0}'</h1>".format(task)
	}

def run(task):
  if task != 'NO_CREDENTIALS':
    import json
    settings = json.load(open("preferences.json"))
    email = settings.get('email')
    password = settings.get('password')
    import httplib
    conn = httplib.HTTPSConnection("api.wunderlist.com")
    conn.request("POST", "/login", '{"email":"'+email+'", "password":"'+password+'"}')
    response = conn.getresponse().read()
    json = json.loads(response)
    token = json.get('token')
    if token is None or token == 'None':
      post_notification("Your Wunderlist credentials are wrong")
    else:
      headers = {"Content-type": "application/json", "Authorization": "Bearer " + token}
      conn.request("POST", "/me/tasks", '{"list":"inbox", "title":"'+task+'"}', headers)
      response = conn.getresponse()
      if response.status == 201:
        post_notification("Wunderlist task created successfully")
      else:
        post_notification("Task creation failed")

def post_notification(message, title="Flashlight"):
  import os, json, pipes
  # do string escaping:
  message = json.dumps(message)
  title = json.dumps(title)
  script = 'display notification {0} with title {1}'.format(message, title)
  os.system("osascript -e {0}".format(pipes.quote(script)))

