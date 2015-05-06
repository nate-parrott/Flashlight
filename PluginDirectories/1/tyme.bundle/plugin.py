#!/usr/bin/python

import re
import webbrowser
from centered_text import centered_text
from applescript import asrun, asquote

def results(parsed, original_query):
	task = parsed.get('~task', 'New task')
	project = parsed.get('~project', 'Inbox')
	tags = extract_tags(parsed)

	html = format_html(task, project, tags)
	run_args = [task, project]
	run_args.append(tags)

	return {
		'title': "Add a new task to Tyme",
		'run_args': run_args,
		'html': centered_text(html)
	}

def extract_tags(parsed):
	# Flashlight recognizes everything after the first hashtag (#) as one tag.
	#	If multiple tags were given, they will be split here.
	tags = parsed.get('~tags', '')
	if len(tags) == 0:
		return []
	return [tag for tag in re.split(r'\s*[#,]\s*', tags) if len(tag) > 0]
	
def format_html(task, project, tags):
	result = open('Template.html', 'r').read()
	result = re.sub(r'<!--TASK-->', task, result)
	result = re.sub(r'<!--PROJECT-->', project, result)

	if len(tags) == 0:
		result = re.sub(r'(?s)<!--IF TAGS-->.+<!--END TAGS-->', '', result)
	result = re.sub(r'<!--TAGS-->', ', '.join(tags), result)

	result = re.sub(r'<!--.+-->', '', result)
	return result
		
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