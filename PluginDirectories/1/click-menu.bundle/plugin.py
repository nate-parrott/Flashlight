# -*- coding: utf-8 -*-

def open_security():
	import os
	os.system("open /System/Library/PreferencePanes/Security.prefPane")

def current_app():
	from applescript import asrun
	return asrun("""
	tell application "System Events"
		get item 1 of (get name of processes whose frontmost is true)
	end tell
	""").strip()

class MenuItem(object):
	title = ""
	parent_menus = []
	applescript = ""
	def match_score(self, query):
		words = self.title.lower().split(' ')
		qwords = query.lower().split(' ')
		score = 0
		for qword in qwords:
			for word in words:
				if word == qword:
					score += 1
				elif word.startswith(qword) or qword.startswith(word):
					score += 0.5
		if query.lower() in self.title.lower():
			score += 0.1
		return score
	def html(self):
		path = u"<ol class='path'>{0}</ol>".format(u"".join([u"<li>{0}</li>".format(menu) for menu in self.parent_menus]))
		return u"<li>{0}<span class='title'>{1}</span></li>".format(path, self.title)
	def full_path(self):
		return self.parent_path() + self.title
	def parent_path(self):
		return u'/'.join(self.parent_menus) + u'/'

def get_cached_text(current_app):
	import cPickle as pickle, os, time
	path = "cached.pickle"
	if os.path.exists(path):
		data = pickle.load(open(path))
		if data['app'] == current_app:
		 age = time.time() - data['time']
		 if age < 7:
			 return data['text']

def cache_text(current_app, text):
	import cPickle as pickle, time
	pickle.dump({"time": time.time(), "app": current_app, "text": text}, open('cached.pickle', 'wb'))

def load_menu_items():
	app = current_app()
	text = get_cached_text(app)
	if not text:
		from time import time
		from applescript import asrun, asquote
		_rstart = time()
		text = asrun("""
		set AppleScript's text item delimiters to {"\n"}
	
		on toString(anyObj)
				local i, txt, errMsg, orgTids, oName, oId, prefix
				set txt to ""
				repeat with i from 1 to 2
						try
								if i is 1 then
										if class of anyObj is list then
												set {orgTids, AppleScript's text item delimiters} to {AppleScript's text item delimiters, {", "}}
												set txt to ("{" & anyObj as string) & "}"
												set AppleScript's text item delimiters to orgTids # '
										else
												set txt to anyObj as string
										end if
								else
										set txt to properties of anyObj as string
								end if
						on error errMsg
								# Trick for records and record-*like* objects:
								# We exploit the fact that the error message contains the desired string representation of the record, so we extract it from there. This (still) works as of AS 2.3 (OS X 10.9).
								try
										set txt to do shell script "egrep -o '\\\\{.*\\\\}' <<< " & quoted form of errMsg
								end try
						end try
						if txt is not "" then exit repeat
				end repeat
				set prefix to ""
				if class of anyObj is not in {text, integer, real, boolean, date, list, record} and anyObj is not missing value then
						set prefix to "[" & class of anyObj
						set oName to ""
						set oId to ""
						try
								set oName to name of anyObj
								if oName is not missing value then set prefix to prefix & " name=\\"" & oName & "\\""
						end try
						try
								set oId to id of anyObj
								if oId is not missing value then set prefix to prefix & " id=" & oId
						end try
						set prefix to prefix & "] "
				end if
				return prefix & txt
		end toString
	
		tell application "System Events"
			tell process %s
				set x to (entire contents of menu bar 1)
			end tell
		end tell
	
		get toString(x)
		"""%(asquote(app)))
		cache_text(app, text)
		
	classes = {
		"«class mbri»": "menu bar item",
		"«class menI»": "menu item",
		"«class mbar»": "menu bar",
		"«class menE»": "menu",
		"«class pcap»": "process"
	}
	
	if text == '':
		return None
	
	for class_name, real_name in classes.iteritems():
		text = text.replace(class_name, real_name)
	
	import re
	items = []
	parent_menus_regex = re.compile(r'of menu "([^"]+?)"')
	for match in re.finditer(r'menu item "(?P<title>[^"]+?)" (?P<parents>(of menu "[^"]+?" .*?)+?) of menu bar 1 of process ".*?"', text):
		item = MenuItem()
		item.title = match.group('title').decode('utf-8')
		item.parent_menus = list(reversed([s.decode('utf-8') for s in [m.group(1) for m in re.finditer(parent_menus_regex, match.group('parents'))]]))
		item.applescript = match.group(0)
		items.append(item)
		
	return items

def menu_items():
	return load_menu_items()

def results(fields, original_query):
	from dark_mode import dark_mode
	items = menu_items()
	if items != None:
		# remove submenus from results:
		menus = set((i.parent_path() for i in items))
		items = [i for i in items if i.full_path() + u"/" not in menus]
		# filter items:
		if '~item' in fields:
			query = fields['~item']
			for item in items:
				item.score = item.match_score(query)
			items = [item for item in items if item.score > 0]
			items.sort(key=lambda x: -x.score)
		# truncate items:
		n_more = max(0, len(items) - 10)
		if n_more:
			items = items[:-n_more]
		# generate html:
		html = u"""
		<style>
		body {
			padding: 0;
			margin: 0;
			font-family: "HelveticaNeue";
		}
		body.dark {
			color: white;
		}
		body.light {
			color: black;
		}
		ol {
			list-style-type: none;
			padding: 0;
			cursor: default;
		}
		ol#items > li {
			border-bottom: 1px solid rgba(120,120,120,0.2);
			padding: 0.5em;
			font-size: small;
		}
		ol#items > li:last-child {
			border-bottom: none;
		}
		ol.path {
			display: inline;
		}
		ol.path > li {
			display: inline-block;
			opacity: 0.6;
		}
		ol.path > li:after {
			content: "⟩";
			display: inline-block;
			padding-left: 0.5em;
			padding-right: 0.5em;
			opacity: 0.7;
		}
		.title {
			font-weight: bold;
		}
		.nmore {
			text-align: center;
			font-size: small;
			opacity: 0.5;
		}
		
		ol#items > li:first-child {
			background-color: rgba(125, 125, 125, 0.3);
		}
		
		/*ol#items:not(:hover) > li:first-child, ol#items:hover > li:hover {
			background-color: rgba(125, 125, 125, 0.3);
		}*/
		
		</style>
		
		<ol id='items'>
		<!--ITEMS-->
		</ol>
		""".replace(u"<!--ITEMS-->", u"".join([i.html() for i in items])).replace("<!--COLOR-->", ("dark" if dark_mode() else "light"))
		if n_more:
			html += u"<p class='nmore'>{0} more...</p>".format(n_more)
	else:
		from centered_text import centered_text
		html = centered_text("""
		<style>
		p {
			margin: 10px;
			font-size: 15px;
		}
		</style>
		<p>Spotlight needs accessibility permissions to search menu items.</p>
		<p><img src='settings.png' style='max-width: 250px'/></p>
		<p><button onclick="flashlight.bash('open /System/Library/PreferencePanes/Security.prefPane')">Open Privacy Settings</button></p>
		""")
	d = {
		"title": "Search menu items",
		"html": html,
		"webview_transparent_background": True
	}
	if items and len(items) > 0:
		d['run_args'] = [items[0].applescript]
	return d

def run(script):
	from applescript import asrun
	script = u"""
	tell application "System Events" to click %s
	"""%(script)
	open('/Users/nateparrott/Desktop/xyz.scpt', 'w').write(script)
	asrun(script.encode('utf-8'))

