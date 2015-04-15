def results(fields, original_query):
	import cgi
	content = u""
	if 'clipboard' in fields:
		import pasteboard
		content = pasteboard.get_text()
	elif '~note' in fields:
		content = fields['~note']
	html = u"""
	<!DOCTYPE html>
	<html>
	<head>
	
	<style>
	body {
		background-image: url(background.png);
		background-size: 128px;
		font-family: "Helvetica Neue";
		line-height: 1.3;
		margin: 0;
	}
	
	html, body {
		height: 100%;
	}
	
	#field {
		box-sizing: border-box;
		padding: 20px;
		padding-bottom: 50px;
		min-height: 100%;
		outline: none;
	}
	
	#field:empty:before {
		content: "Type some text, or say 'from clipboard'";
		opacity: 0.5;
	}
	
	#save {
		background-color: white;
		border-top: 0.5px solid rgba(0,0,0,0.75);
		padding: 10px;
		text-align: center;
		text-transform: uppercase;
		color: rgba(0,0,0,0.5);
		font-weight: bold;
		font-size: small;
		position: fixed;
		bottom: 0;
		left: 0;
		right: 0;
		cursor: default;
	}
	</style>
	
	<script>
	function output() {
		return document.getElementById("field").innerText;
	}
	</script>
	
	</head>
	<body>
	
	<div id='field' contentEditable><!--CONTENT--></div>
	
	<div id='save' onClick="flashlight.invoke()">
	Save note
	</div>
	
	</body>
	</html>
	""".replace("<!--CONTENT-->", cgi.escape(content).replace("\n", "<br/>"))
	return {
		"title": "Create a note",
		"html": html,
		"run_args": [],
		"pass_result_of_output_function_as_first_run_arg": True
	}

def run(content):
	from applescript import asrun, asquote
	name = content.split("\n")[0]
	if len(name) == 0: name = "New note"
	script = u"""tell application "Notes"
		set theContainerFolder to container of first note
		set theNote to make new note at theContainerFolder with properties {body:<!--BODY-->, name:<!--NAME-->}
	  display notification "Created note" with title "Flashlight"
	end tell
	""".replace("<!--BODY-->", asquote(content)).replace("<!--NAME-->", asquote(name))
	asrun(script)
