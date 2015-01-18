def results(fields, original_query):
  channel_n = fields['~channel']
  message_n = fields['~message']
  channel_split = channel_n.split()
  channel = channel_split[0]
  message = ""
  for x in xrange(1,len(channel_split)):
  	message = message + channel_split[x] + " "
  message = message + message_n
  import json
  settings = json.load(open("preferences.json"))
  url = settings.get('url')
  user = settings.get('user')
  if user is None or user == '' or url is None or url == '':
    return {
	    "title": "Slack {0} '{1}'".format(channel, message),
	    "run_args": ['NO_CREDENTIALS', ''],
		"html": "<h2 style='font-family: sans-serif; padding: 2em'>Setup an 'Incoming WebHook' integration in Slack and enter the URL and your username in the plugin settings</h2>"
	}
  else:
    return {
	    "title": "Slack {0} '{1}'".format(channel, message),
	    "run_args": [channel, message],
		"html": "<h2 style='font-family: sans-serif; padding: 2em'>Message to '{0}': '{1}'</h2>".format(channel, message)
	}

def run(channel, message):
  if channel != 'NO_CREDENTIALS':
    import json
    settings = json.load(open("preferences.json"))
    url = settings.get('url')
    user = settings.get('user')
    import httplib, urllib2
    conn = httplib.HTTPSConnection("hooks.slack.com")
    resource = url.partition("hooks.slack.com")[2]
    payload = { "channel": channel, "username": user, "text": message}
    conn.request("POST", resource, json.dumps(payload))
    response = conn.getresponse()
    if response.status == 200:
      post_notification("Message posted successfully")
    else:
      post_notification("Message failed")

def post_notification(message, title="Flashlight"):
  import os, json, pipes
  # do string escaping:
  message = json.dumps(message)
  title = json.dumps(title)
  script = 'display notification {0} with title {1}'.format(message, title)
  os.system("osascript -e {0}".format(pipes.quote(script)))
