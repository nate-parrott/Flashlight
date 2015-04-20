
label_preferences = ["_$!<Main>!$_", "iPhone", "_$!<Mobile>!$_", "_$!<Work>!$_"]
label_map = {
	"label/work": "_$!<Work>!$_",
	"label/home": "_$!<Home>!$_",
	"label/mobile": "_$!<Mobile>!$_",
	"label/main": "_$!<Main>!$_"
} 

def find_contact(fields):
	for field in fields:
		if field.startswith('@contact/'):
			return fields[field]
	digit = fields.get('~digit')
	return {"displayName": digit, "Phone": {"typed": digit}}

def get_preferred_phone(fields, contact):
	phones = contact.get('Phone', {})
	for label_field, label in label_map.iteritems():
		if label_field in fields and label in phones:
			return phones[label]
	for label in label_preferences:
		if label in phones:
			return phones[label]
	if len(phones.values()):
		return phones.values()[0]
	return None

def results(fields, original_query):
	contact = find_contact(fields)
	phone = get_preferred_phone(fields, contact)	
	facetime = 'facetime' in original_query
	action = 'FaceTime' if facetime else 'Call'
	name = contact.get('displayName', phone)
	title = u"{0} {1}".format(action, name)
	from centered_text import centered_text
	if name == phone:
		html = centered_text(u"<p><span class='icon-phone'></span> {0}</p>".format(phone))
	else:
		html = centered_text(u" <h1>{0}</h1> <p><span class='icon-phone'></span> {1}</p>  ".format(name, phone))
	return {
		"title": title,
		"html": html,
		"webview_transparent_background": True,
		"run_args": [phone, facetime]
	}
	

def run(digit, is_facetime):
		import os
		from applescript import asrun
		import time
		
		digit = ''.join((c for c in digit if c in '0123456789+'))
		if is_facetime:
				os.popen('open facetime://{0}'.format(digit))
		else:
				os.popen('open tel://{0}'.format(digit))

		asrun("tell application \"Facetime\" to activate")
		time.sleep(2)
		asrun("tell application \"System Events\" to keystroke return")

