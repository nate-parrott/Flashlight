def results(fields, original_query):
	hostname = fields['~hostname']
	hostnameL = hostname.lower()
	args = [hostname]

	protocol = "";

	if hostnameL.startswith("rdp://"):
		protocol = "RDP"
		hostname = hostname[6:]
	elif hostnameL.startswith("vnc://"):
		protocol = "VNC"
		hostname = hostname[6:]
	elif hostnameL.startswith("terminal://"):
		protocol = "Terminal"
		hostname = hostname[11:]
	elif hostnameL.startswith("ssh://"):
		protocol = "SSH"
		hostname = hostname[6:]
	elif hostnameL.startswith("telnet://"):
		protocol = "Telnet"
		hostname = hostname[9:]
	elif hostnameL.startswith("web://"):
		protocol = "Web"
		hostname = hostname[6:]
	elif hostnameL.startswith("http://"):
		protocol = "HTTP"
		hostname = hostname[7:]
	elif hostnameL.startswith("https://"):
		protocol = "HTTPS"
		hostname = hostname[8:]
	elif hostnameL.startswith("windowsevents://"):
		protocol = "Windows Events"
		hostname = hostname[16:]
	elif hostnameL.startswith("winevt://"):
		protocol = "Windows Events"
		hostname = hostname[9:]
	elif hostnameL.startswith("windowsservices://"):
		protocol = "Windows Services"
		hostname = hostname[18:]
	elif hostnameL.startswith("winsvc://"):
		protocol = "Windows Services"
		hostname = hostname[9:]
	elif hostnameL.startswith("windowsprocesses://"):
		protocol = "Windows Processes"
		hostname = hostname[19:]
	elif hostnameL.startswith("winproc://"):
		protocol = "Windows Processes"
		hostname = hostname[10:]
	elif hostnameL.startswith("terminalservices://"):
		protocol = "Terminal Services"
		hostname = hostname[19:]
	elif hostnameL.startswith("termsvc://"):
		protocol = "Terminal Services"
		hostname = hostname[10:]
	elif hostnameL.startswith("hyperv://"):
		protocol = "Hyper-V"
		hostname = hostname[9:]

	title = "Royal TSX: Connect Ad-hoc"

	htmlH1 = "<h1 style='font-family: sans-serif; font-weight: normal; font-size: 20px; margin: 0; padding: 10px 10px 8px 10px;'>Royal TSX</h1>"
	htmlH2 = "<h2 style='font-family: sans-serif; font-weight: normal; font-size: 13px; margin: 0; padding: 0px 10px 15px 10px; color: grey;'>Connect Ad-hoc<br />Tip: You can use protocol specifiers (rdp://, ssh://, etc...)</h2>"

	htmlP2 = ""

	if protocol:
		htmlP2 = "<br />Protocol: <strong>{0}</strong>".format(protocol)

	htmlP  = "<p style='font-family: sans-serif; font-size: 13px; margin: 0; padding: 0px 10px 0px 10px;'>Hostname: <strong>{0}</strong>{1}</p>".format(hostname, htmlP2)

	html   = htmlH1 + htmlH2 + htmlP
	
	return {
		"title": title,
		"run_args": args,
		"html": html,
		"webview_transparent_background": True
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