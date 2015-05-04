#!/usr/bin/python

import re
from applescript import asrun, asquote

def results(parsed, original_query):
	task = parsed.get('~task', 'New task')
	project = parsed.get('~project', 'Inbox')
	tags = extract_tags(parsed)

	html = format_html(task, project, tags)
	title = remove_html_tags(html)
	run_args = [task, project]
	run_args.append(tags)

	return {
		"title": title,
		"run_args": run_args,
		"html": html
	}

def extract_tags(parsed):
	# Flashlight recognizes everything after the first hashtag (#) as one tag.
	#	If multiple tags were given, they will be split here.
	tags = parsed.get('~tags', '')
	if len(tags) == 0:
		return []
	return re.split(r'\s*[#,]\s*', tags)
	
def format_html(task, project, tags):
	result = "<h1><u>Tyme:</u><br>" \
		+ "Add task <i>{}</i><br>".format(task) \
		+ "into project <i>{}</i>".format(project)
	if len(tags) > 0:
		result = result + "<br>with tags <i>{}</i>".format(', '.join(tags))
	return result + "</h1>"
	
def remove_html_tags(html):
	result = re.sub(r'</?i>', '\'', html)
	result = re.sub(r'<br>', ' ', result)
	return re.sub(r'<.*?>', '', result)
	
def run(*args):
	task, project, tags = args
	create_new_task(task, project)
	for tag in tags:
		add_tag(tag, task, project)
	
def create_new_task(task, project):
	ascript_body = '''set projectName to {0}
	if ((count of (every project whose name = projectName)) = 0) then
		make new project with properties {{name:projectName, archived:false}}
	end if
	set targetProject to first item of (every project whose name = projectName)
	make new task with properties {{name:{1}}} at the end of targetProject'''.format(asquote(project), asquote(task))
	return run_tyme_script(ascript_body)

def add_tag(tag, task, project):
	ascript_body = '''set targetProject to first item of (every project whose name = {0})
	set targetTask to first item of (every task of targetProject whose name = {1})
	make new taskTag with properties {{name:{2}}} at the end of targetTask'''.format(asquote(project), asquote(task), asquote(tag))
	run_tyme_script(ascript_body)

def run_tyme_script(ascript_body):
	return asrun('''tell application "Tyme"
	activate
	{}
	activate
end tell'''.format(ascript_body))