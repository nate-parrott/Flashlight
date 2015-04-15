def results(fields, original_query):
  message = fields['~message']
  return {
    "title": "Say '{0}'".format(message),
    "run_args": [message],
	"html": "<h1 style='font-family: sans-serif; padding: 2em'>{0}</h1>".format(message)
  }

def run(message):
  import os, pipes
  os.system('say "{0}"'.format(pipes.quote(message.encode('utf8'))))

