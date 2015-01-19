from applescript import asrun, asquote

def create_event(name, from_date, to_date, location):
	import datetime
	def timestamp_to_applescript(timestamp):
		string = datetime.datetime.fromtimestamp(timestamp).strftime("%m/%d/%Y %I:%M:%S %p")
		return ' date "{0}"'.format(string)
	
	props = {"summary": asquote(name), "start date": timestamp_to_applescript(from_date), "end date": timestamp_to_applescript(to_date)}
	if location:
		props['location'] = asquote(location)
	props_str = u"{" + u", ".join([u"{0}:{1}".format(key, value) for (key, value) in props.iteritems()]) + u"}"
	
	script = u"""
	tell application "Calendar"
	 activate
	 set newEvent to make new event at end of events of calendar "Home" with properties {0}
	 show newEvent
	end tell
	""".format(props_str)
	print script
	asrun(script)

if __name__ == '__main__':
	create_event("test event", None, None, "hell")
