import json, urllib2, base64

def results(fields, original_query):
  task = fields['~task']
  settings = json.load(open("preferences.json"))
  api_key = settings.get('api_key')
  if api_key is None or api_key == '':
    return {
	    "title": "asana '{0}'".format(task),
	    "run_args": ['NO_CREDENTIALS', ''],
		"html": "<h2 style='font-family: sans-serif; padding: 2em'>Enter your Asana API key in the plugin settings</h2>"
	}
  else:
    return {
    	"title": "asana '{0}'".format(task),
    	"run_args": [task, api_key],
		"html": "<h1 style='font-family: sans-serif; padding: 2em'>Create task '{0}'</h1>".format(task)
		}

def run(task, api_key):
  if task == 'NO_CREDENTIALS':
  	return
  workspaces = get_all_workspaces(api_key)
  if workspaces is None:
  	post_notification('Please check your Asana API key')
  	return
  chosen_space = get_chosen_workspace()
  space_id = get_workspace_id(chosen_space, workspaces)
  if space_id is None:
    post_notification('Failed to find your Asana workspace')
    return
  user_id = get_user_id(api_key)
  create_task(user_id, space_id, task, api_key)
  post_notification('Asana task has been created!')

def get_workspace_id(chosen_space, workspaces):
  space_id = None
  for x in xrange(0,len(workspaces)):
    if workspaces[x].get('name') == chosen_space:
      space_id = workspaces[x].get('id')
      break
  return space_id

def get_all_workspaces(api_key):
  request = urllib2.Request("https://app.asana.com/api/1.0/workspaces")
  base64string = base64.encodestring('%s:%s' % (api_key, '')).replace('\n', '')
  request.add_header("Authorization", "Basic %s" % base64string)   
  try:
    result = urllib2.urlopen(request)
    workspaces = json.load(result).get('data')
  except:
    workspaces = None
  return workspaces

def create_task(user_id, space_id, task, api_key):
  task_data = {"data" : {"workspace" : space_id, "name" : task, "assignee": {"id": user_id}}}
  request = urllib2.Request(url="https://app.asana.com/api/1.0/tasks", data=json.dumps(task_data))
  base64string = base64.encodestring('%s:%s' % (api_key, '')).replace('\n', '')
  request.add_header("Authorization", "Basic %s" % base64string)   
  request.add_header('Content-Type', 'application/json')
  result = urllib2.urlopen(request)

def get_user_id(api_key):
  request = urllib2.Request("https://app.asana.com/api/1.0/users/me")
  base64string = base64.encodestring('%s:%s' % (api_key, '')).replace('\n', '')
  request.add_header("Authorization", "Basic %s" % base64string)   
  result = urllib2.urlopen(request)
  user_id = json.load(result).get('data').get('id')
  return user_id

def get_chosen_workspace():
  settings = json.load(open("preferences.json"))
  workspace = settings.get('workspace')
  chosen_space = 'Personal Projects'
  if workspace != 'personal':
    chosen_space = settings.get('orgainzation_name')
    if chosen_space is None or chosen_space == '':
  	  chosen_space = 'Personal Projects'
  return chosen_space

def post_notification(message, title="Flashlight"):
  import os, json, pipes
  # do string escaping:
  message = json.dumps(message)
  title = json.dumps(title)
  script = 'display notification {0} with title {1}'.format(message, title)
  os.system("osascript -e {0}".format(pipes.quote(script)))
