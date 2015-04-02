def results(fields, original_query):
	hostname = fields['~hostname']
	args = [hostname]

	title = "Royal TSX: Connect Ad-hoc"

	htmlH1 = "<h1 style='font-family: sans-serif; font-weight: normal; font-size: 20px; margin: 0; padding: 10px 10px 8px 10px;'>Royal TSX</h1>"
	htmlH2 = "<h2 style='font-family: sans-serif; font-weight: normal; font-size: 13px; margin: 0; padding: 0px 10px 15px 10px; color: grey;'>Connect Ad-hoc<br />Tip: You can use protocol specifiers (rdp://, ssh://, etc...)</h2>"
	htmlP  = "<p style='font-family: sans-serif; font-size: 13px; margin: 0; padding: 0px 10px 0px 10px;'>Hostname: <strong>{0}</strong></p>".format(hostname)
	html   = htmlH1 + htmlH2 + htmlP
	
	return {
		"title": title,
		"run_args": args,
		"html": html
	}

def runAppleScript(script, args=[]):
	from subprocess import Popen, PIPE

	p = Popen(['osascript', '-'] + args, stdin=PIPE, stdout=PIPE, stderr=PIPE)
	p.communicate(script)

def run(hostname):
	script = '''
    tell application "Royal TSX"
    	activate
    	delay 0.5
        adhoc "{0}"
    end tell
    '''.format(hostname)

	runAppleScript(script)