import json
import pipes

def results(fields, original_query):
	message = fields['~message']
	return {
		"title": "on {0}".format(message),
		"run_args": [message],
	"html": "<h1 style='font-family: sans-serif; padding: 2em'>I'm working on {0}</h1>".format(message)
	}

def run(message):
	import os
	token = json.load(open('preferences.json'))['token']
	if len(token) == 0:
		os.system('open "flashlight://plugin/workingon/preferences"')
	else:
		os.system('curl -X POST --data-urlencode "task={0}" https://api.workingon.co/hooks/incoming?token={1} >/dev/null 2>&1;'.format(pipes.quote(message.encode('utf8')),token))
