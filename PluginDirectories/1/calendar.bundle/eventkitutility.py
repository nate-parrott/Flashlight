import json, subprocess, os, stat

def _chmod_plus_x(file):
	st = os.stat(file)
	os.chmod(file, st.st_mode | stat.S_IEXEC)

def create_events(events):
	_chmod_plus_x('EventKitUtility')
	return json.loads(subprocess.check_output(["./EventKitUtility", json.dumps(events)]))
