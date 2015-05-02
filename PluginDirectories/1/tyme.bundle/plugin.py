#!/usr/bin/python

from applescript import asrun, asquote

def results(parsed, original_query):
	task = parsed.get('~task', 'New task')
	project = parsed.get('~project', 'Inbox')

	run_args = [task, project]
	run_args.append(extract_tags(parsed))

	return {
		"title": "Add task '{}' in Tyme into project '{}'".format(task, project),
		"run_args": run_args
	}

def extract_tags(parsed):
	# Flashlight recognizes everything after the first hashtag (#) as one tag.
	#	If multiple tags were given, they will be split here.
	tags = parsed.get('~tags', '')
	if len(tags) == 0:
		return []
	return [tag.strip() for tag in tags.split('#')]
	
def run(*args):
	task, project, tags = args
	create_new_task(task, project)
	for tag in tags:
		add_tag(tag, task, project)
	
def create_new_task(task, project):
	asrun('''tell application "Tyme"
	activate
	
	set projectName to {0}
	if ((count of (every project whose name = projectName)) = 0) then
		make new project with properties {{name:projectName, archived:false}}
	end if
	set targetProject to first item of (every project whose name = projectName)
	
	make new task with properties {{name:{1}}} at the end of targetProject
	activate
end tell'''.format(asquote(project), asquote(task)))


def add_tag(tag, task, project):
	asrun('''tell application "Tyme"
	activate
	set targetProject to first item of (every project whose name = {0})
	set targetTask to first item of (every task of targetProject whose name = {1})
	make new taskTag with properties {{name:{2}}} at the end of targetTask
	activate
end tell'''.format(asquote(project), asquote(task), asquote(tag)))
	