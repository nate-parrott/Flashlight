#!/usr/bin/python

import re
import webbrowser

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
		"html": html
	}

def extract_tags(parsed):
	# Flashlight recognizes everything after the first hashtag (#) as one tag.
	#	If multiple tags were given, they will be split here.
	tags = parsed.get('~tags', '')
	if len(tags) == 0:
		return []
	return re.split(r'\s*[#,]\s*', tags)
	
def format_html(task, list_name, tags):
	result = "<h1><u>2do:</u><br>" \
		+ "Add task <i>{}</i><br>".format(task) \
		+ "to list <i>{}</i>".format(list_name)
	if len(tags) > 0:
		result = result + "<br>with tags <i>{}</i>".format(', '.join(tags))
	return result + "</h1>"
	
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
