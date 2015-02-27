def results(parsed, original_query):
	import json
	settings = json.load(open("preferences.json"))
  	username = settings.get('username')
  	password = settings.get('password')
  	if username is None or username == '' or password is None or password == '':
		return {
  			"title": "Add task '{0}' to TickTick".format(parsed['~title'].encode('utf-8')),
  			"run_args": ['NO_CREDENTIALS', ''],
  			"html": "<h2 style='font-family: sans-serif; padding: 2em'>You need to set your TickTick account first.</h2>"
  	  	}
  	else:
  		return {
  			"title": "Add task '{0}' to TickTick".format(parsed['~title'].encode('utf-8')),
  			"run_args": [parsed['~title'].encode('utf-8')],
            "html": "<h1 style='font-family: sans-serif; padding: 2em'>Create task : '{0}'</h1>".format(parsed['~title'].encode('utf-8'))
  		}

def run(title):
    import json
    import httplib, urllib2
    conn = httplib.HTTPSConnection("ticktick.com")
    settings = json.load(open("preferences.json"))
    username = settings.get('username')
    password = settings.get('password')
    authinfo = {"username": username, "password": password}
    headers = {"Content-type" : "application/json"}
    conn.request("POST", "/api/v2/user/signon", json.dumps(authinfo), headers)
    response = conn.getresponse().read()
    json = json.loads(response)
    token = json.get('token')
    if token is None or token == '':
    	post_notification("Your TickTick credentials are wrong")
    else:
	    payload = { "title": title}
	    headers = {"Content-type" : "application/json","Cookie" : "t=" + token }
	    conn.request("POST", "/api/v2/task", '{"title":"'+title+'"}', headers)
	    response = conn.getresponse()
	    if response.status == 200:
	      post_notification("Create new task: " + title)
	    else:
	      post_notification(response.status)

def post_notification(message, title="TickTick"):
  import os, json, pipes
  # do string escaping:
  message = json.dumps(message)
  title = json.dumps(title)
  script = 'display notification {0} with title {1}'.format(message, title)
  os.system("osascript -e {0}".format(pipes.quote(script)))