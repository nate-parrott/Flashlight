from pipes import quote
def open_command(path):
	return u"open -R {0}".format(quote(path))

import json, os

def results(fields, original_query):
	from dark_mode import dark_mode
	def li_for_path(path):
		base, filename = os.path.split(path)
		command = json.dumps(open_command(path))
		return u"""<li onclick='flashlight.bash({0})'><strong>{1}</strong> <span>from {2}</span></li>""".format(command, filename, base)
	paths = [fields['@file']['path']] + fields['@file']['otherPaths']
	rows = u"".join(map(li_for_path, paths))
	html = u"""
	<style>
	body {
		margin: 0;
		font-family: sans-serif;
		color: <!--COLOR-->;
	}
	ul {
		padding: 0;
	}
	li {
		list-style-type: none;
		padding: 10px;
		border-bottom: 1px solid rgba(0,0,0,0.2);
		cursor: default;
	}
	li:last-child {
		border-bottom: none;
	}
	li span {
		opacity: 0.7;
	}
	ul:not(:hover) li:first-child, li:hover {
		background-color: rgba(100,100,100,0.1);
	}
	</style>
	<ul>
	<!--ROWS-->
	</ul>
	""".replace("<!--COLOR-->", 'white' if dark_mode() else 'black').replace('<!--ROWS-->', rows)
	return {
		"title": "Reveal in Finder",
		"html": html,
		"run_args": [paths[0] if len(paths) else None],
		"webview_transparent_background": True
	}

def run(path):
	import os
	if path:
		os.system(open_command(path))