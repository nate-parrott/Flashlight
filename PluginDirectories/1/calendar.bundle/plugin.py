import urllib, json, datetime, time
from eventkitutility import create_events
from post_notification import post_notification

def html_from_date_obj(date_obj):
	if date_obj == None:
		# return placeholder date markup:
		return "<span class='datetime'><span class='date'>???<span class='day_of_month'>?</span></span> <span class='time'>??:??</span></span>"
	time = datetime.datetime.fromtimestamp(int(date_obj['timestamp']))
	return time.strftime("<span class='datetime'><span class='date'>%a, %b <span class='day_of_month'>%d</span></span> <span class='time'>%I:%M %p</span></span>")

def ensure_end_date_is_later(dates):
	if len(dates) == 2:
		if dates[0]['timestamp'] > dates[1]['timestamp']:
			start = datetime.datetime.fromtimestamp(dates[0]['timestamp'])
			end = datetime.datetime.fromtimestamp(dates[1]['timestamp'])
			#end = datetime.datetime(year=start.year, month=start.month, day=start.day, hour=end.hour, minute=end.minute, second=end.second)
			end_timestamp = (end - datetime.datetime.fromtimestamp(0)).total_seconds()
			while end_timestamp < dates[0]['timestamp']:
				end_timestamp += 24 * 60 * 60 # add a day
			dates[1]['timestamp'] = end_timestamp

def safe_format(text, **kwargs):
	from collections import defaultdict
	d = defaultdict(lambda x: "")
	for k, v in kwargs.iteritems():
		d[k] = v
	return text.format(**d)

def results(parsed, original_query, object):
	from dark_mode import dark_mode
	
	body_class = 'dark' if dark_mode else 'light'
	
	dates = []
	if '@date_all' in parsed:
		dates = parsed['@date_all']
	elif '@date' in parsed:
		dates = [parsed['@date']]
	ensure_end_date_is_later(dates)
	if len(dates) == 0:
		dates.append({"timestamp": time.time()})
	if len(dates) == 1:
		dates.append({"timestamp": dates[0]['timestamp'] + 60 * 60})
	
	date_strings = map(html_from_date_obj, dates)
	if len(dates) > 1:
		date_strings.insert(1, "<span class='dash'>&mdash;</span>")
	
	event = parsed.get('~name', "Calendar Event")
	
	location = parsed.get('~location', None)
	
	from jinja2 import Template
	html = Template(open("template.html").read()).render({
		"dates": date_strings,
		"event": event,
		"location": location,
		"color": 'dark' if dark_mode() else 'light'
	})
	
	from_date = dates[0]['timestamp'] if len(dates) else None
	to_date = dates[1]['timestamp'] if len(dates) > 1 else None
	return {
			"title": json.loads(open("info.json").read())['displayName'],
			"run_args": [event, from_date, to_date, location],
			"html": html,
			"webview_transparent_background": True
	}

def run(*args):
	event, from_date, to_date, location = args
	success = all(create_events([{
		"type": "event",
		"title": event,
		"date": from_date,
		"endDate": to_date
	}]))
	post_notification("Created event" if success else "Failed to create event")
