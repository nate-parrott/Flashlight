#!/usr/bin/python

import subprocess
import re
import cgi

def results(fields, original_query):
	query = fields['~query']
  	return {
    		"title": "Searching your notes for {0}".format(query),
    		"run_args": [],
		"html": createHTML(query)
  	}

def run():
	print ''

def asrun(ascript):
	osa = subprocess.Popen(['osascript', '-'],
		stdin=subprocess.PIPE,
		stdout=subprocess.PIPE)
	return osa.communicate(ascript)[0]

def getEvernoteSearchResults(query):
	script = '''
	tell application "Evernote"
		set find_results to find notes "{0}"
		set output_list to {}
		repeat with find_result in find_results
			set o_title to get title of find_result
			set o_id to local id of find_result
			set o_notebook to name of notebook of find_result
			set end of output_list to {title:o_title, local id:o_id, notebook:o_notebook}
		end repeat
		get output_list
	end tell
	'''.replace('{0}', query)
	return asrun(script)

def createHTML(query):
	results = getEvernoteSearchResults(query)
	html = '''
	<!DOCTYPE html>
	<html>
		<head>
			<style>
			html {
				background-color: #eaedef;
			}
			a {
				text-decoration: none;
				padding: 20px;
				display: block;
			}
			a:hover {
				border: 1px solid #ced8df;
			}
			header {
				color: #404040;
				font-family: Helvetica, Arial, sans-serif;
				font-size: 16px;
				margin-bottom: 5px;
			}
			small {
				color: #555e64;
				font-family: Helvetica, Arial, sans-serif;
				font-size: 11px;
				vertical-align: bottom;
			}
			i {
				background-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAVUlEQVR42mNgGFSguL5Nq7C2bSkQ/ycCH8AwACh4tbCuPZAYy4BqH2IT/IBuE5o8XGzUgCFlQEFdq3dBbdsZUPogywBseHAYAPTWRmwGPCHCgM/IegAsqyv9CNAK4AAAAABJRU5ErkJggg==');
				width: 16px;
				height: 16px;
				display: inline-block;
				vertical-align: top;
			}
			</style>
		</head>
		<body>
	'''
	for line in re.split(',\stitle:', results[6:]):
		m = re.match('(.*),\sid:(.*), notebook:(.*)', line)
		html += '''
		<a onclick="openNote('{1}', '{2}', '{0}');">
			<header>{0}</header>
			<i></i>
			<small>{2}</small>
		</a>
		'''.format(cgi.escape(m.group(1)), cgi.escape(m.group(2)), cgi.escape(m.group(3)))
	html += '''
		</body>
		<script>
	 		function line(s) {
        			return ' -e \\'' + s + '\\'';
        		}
			function openNote(id, notebook, title) {
				var script = 'osascript';
				script += line('tell application "Evernote"');
				script += line('open note window with note id "' + id + '" of notebook "' + notebook + '"');
				script += line('activate');
				script += line('end tell');
				flashlight.bash(script);
			} 
		</script>
	</html>
	'''
	return html