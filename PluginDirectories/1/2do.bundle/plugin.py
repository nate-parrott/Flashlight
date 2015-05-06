#!/usr/bin/python

import re
import webbrowser
from centered_text import centered_text

def results(parsed, original_query):
	task = parsed.get('~task', 'New task')
	list_name = parsed.get('~list', '')
	tags = extract_tags(parsed)

	html = format_html(task, list_name, tags)
	run_args = [task, list_name]
	run_args.append(tags)

	return {
		'title': "Add a new task to 2Do",
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
	
def format_html(task, list, tags):
	result = open('Template.html', 'r').read()
	result = re.sub(r'<!--TASK-->', task, result)

	if len(list) == 0:
		result = re.sub(r'(?s)<!--IF LIST-->.+<!--ELSE LIST-->', '', result)
	else:
		result = re.sub(r'(?s)<!--ELSE LIST-->.+<!--END LIST-->', '', result)
	result = re.sub(r'<!--LIST-->', list, result)

	if len(tags) == 0:
		result = re.sub(r'(?s)<!--IF TAGS-->.+<!--END TAGS-->', '', result)
	result = re.sub(r'<!--TAGS-->', ', '.join(tags), result)

	result = re.sub(r'<!--.+-->', '', result)
	return result
	
def run(*args):
	task, list_name, tags = args
	url_parts = ['twodo://x-callback-url/add?task={}'.format(task)]
	if len(list_name) > 0:
		url_parts.append('forlist={}'.format(list_name))
	if len(tags) > 0:
		url_parts.append('tags={}'.format('%2C'.join(tags)))
	return webbrowser.open('&'.join(url_parts))
