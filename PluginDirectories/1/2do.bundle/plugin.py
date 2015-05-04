#!/usr/bin/python

import re
import webbrowser
from centered_text import centered_text

def results(parsed, original_query):
	task = parsed.get('~task', 'New task')
	list_name = parsed.get('~list', '')
	tags = extract_tags(parsed)

	html = format_html(task, list_name, tags)
	title = remove_html_tags(html)
	run_args = [task, list_name]
	run_args.append(tags)

	return {
		"title": title,
		"run_args": run_args,
		"html": centered_text(html)
	}

def extract_tags(parsed):
	# Flashlight recognizes everything after the first hashtag (#) as one tag.
	#	If multiple tags were given, they will be split here.
	tags = parsed.get('~tags', '')
	if len(tags) == 0:
		return []
	return re.split(r'\s*[#,]\s*', tags)
	
def format_html(task, list_name, tags):
	result = ['<img src="Icon.png" alt="2Do" style="width:64px;height:64px">']
	result.append('<h2>Add task <i>{}</i></h2>'.format(task))

	if len(list_name) > 0:
		result.append('<h2>to list <i>{}</i></h2>'.format(list_name))
	else:
		result.append('<h2>to default list</h2>')

	if len(tags) > 0:
		result.append('<h2>with tags <i>{}</i></h2>'.format(', '.join(tags)))

	return ''.join(result)
	
def remove_html_tags(html):
	result = re.sub(r'</?i>', '\'', html)
	result = re.sub(r'<br>', ' ', result)
	return re.sub(r'<.*?>', '', result)
	
def run(*args):
	task, list_name, tags = args
	url_parts = ['twodo://x-callback-url/add?task={}'.format(task)]
	if len(list_name) > 0:
		url_parts.append('forlist={}'.format(list_name))
	if len(tags) > 0:
		url_parts.append('tags={}'.format('%2C'.join(tags)))
	return webbrowser.open('&'.join(url_parts))
