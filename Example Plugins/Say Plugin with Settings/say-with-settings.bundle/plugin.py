import json
settings = json.load(open("preferences.json"))
shortcuts_dict = {}
for shortcut in settings.get('shortcuts', []):
	shortcuts_dict[shortcut['shortcut'].lower()] = shortcut['message']

def results(fields, original_query):
  message = fields['~message']
  if message.lower() in shortcuts_dict:
	  message = shortcuts_dict[message.lower()]
  message = settings.get("greeting", " ") + " " + message
  return {
	"title": "Say '{0}'".format(message),
	"run_args": [message],
	"html": """
		<div style='font-family: sans-serif; padding: 2em'>
			<h1>{0}</h1>
			<p><a href='flashlight://plugin/say-with-settings/preferences'>Open Settings</a></p>
		</div>
		""".format(message)
  }

def run(message):
  import os, pipes
  voice = settings.get('voice')
  rate = "-r 400" if settings.get("fast", False) else ""
  os.system('say -v "{0}" {1} "{2}"'.format(voice, rate, pipes.quote(message.encode('utf8'))))

