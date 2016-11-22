import urllib, json, os

def results(fields, original_query):
  input = fields['~ip']
  return {
    "title": "Screen share '{0}'".format(input),
    "run_args": [input]
  }

def run(input):
  settings = json.load(open('preferences.json'))
  presets = settings["presets"]
  for preset in presets:
    if input == preset["name"]:
      input = preset["ip"]
  os.system('open vnc://"{0}"'.format(input))