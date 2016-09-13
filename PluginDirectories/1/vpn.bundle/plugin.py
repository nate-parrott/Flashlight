def results(fields, original_query):

	# check if vpn exists
	from subprocess import Popen, PIPE
	import os, sys

	vpn_name = fields['~message']
	cmd = """
	osascript -e 'tell application "System Events"
		tell current location of network preferences
			try
				service "%s"
				return 1
			on error
				return 0
			end try
		end tell
	end tell'
	""" % vpn_name

	res, tError = Popen(cmd, shell=True, stdin=PIPE, stdout=PIPE, stderr=PIPE).communicate()
	
	if int(res) == 1:
		html = html_for_vpn_exists(vpn_name)
	else:
		html = html_for_vpn_does_not_exist(vpn_name)

	# "html": "<h1 style='font-family: sans-serif; padding: 2em'>{0}</h1>".format(result)
	return {
	"title": "",
	"run_args": [vpn_name],
	"html": html
	}

def run(message):
	import os

	cmd = """
	osascript -e 'tell application "System Events"
		tell current location of network preferences
			set VPN to "%s"
			set VPNactive to connected of current configuration of service VPN
			if VPNactive then
				disconnect service VPN
			else
				connect service VPN
			end if
		end tell
	end tell' 
	""" % message
	os.system(cmd)

def html_for_vpn_exists(vpn_name):
	return "<html><body style=background-color:#E2E2E2;font-family:helvetica><div style=background-color:#39AE33;color:#F0EFF4;text-align:center;padding:1em><div><p style='font-size:2em;margin:0 auto'>vpn <span style=font-style:italic>{0}</span> exists</p></div></div><img src=ClipArt.png style='display:block;margin:50px auto 20px' width=200px><div><p style='font-size:2em;text-align:center;color:#3CA437;'>press enter to connect</p></div>".format(vpn_name)

def html_for_vpn_does_not_exist(vpn_name):
	return "<html><body style=background-color:#E2E2E2;font-family:helvetica><div style=background-color:#F85555;font-family:helvetica;color:#F0EFF4;text-align:center;padding:1em><div><p style='font-size:2em;margin:0 auto'>VPN <span style=font-style:italic>{0}</span> doesn't exist</p></div></div><img src=ClipArt.png style='display:block;margin:50px auto 20px' width=200px><div><p style='font-size:1em;text-align:center'>VPN needs to be defined in <br> System Preferences -> Network</p></div>".format(vpn_name)