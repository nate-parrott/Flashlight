import os

def get_all(parsed, key):
	if key+'_all' in parsed:
		return parsed.get(key+'_all')
	elif key in parsed:
		return [parsed[key]]
	else:
		return []

def get_contacts(d):
	for key, val in d.iteritems():
		if key == '@contact' or key.startswith('@contact/'):
			yield val

def get_emails(parsed):
	emails = []
	for recip in get_all(parsed, 'recip'):
		for contact in get_contacts(recip):
			contact_emails = contact.get('Email', {}).values()
			if len(contact_emails):
				emails.append(contact_emails[0])
		if 'email' in recip:
			emails.append(recip['email'])
	return emails

def get_attachment(parsed):
	return parsed.get('@file', {}).get('path', None)

def results(parsed, original_query):
		dict = {
				"title": "Send an email",
				"run_args": [parsed],
				"html": html(parsed),
				"webview_transparent_background": True
		}
		return dict

def html(parsed):
		import os
		recips = get_emails(parsed)
		subject = parsed.get('~subject', '')
		body = parsed.get('~message', '')
		attach = u""
		if get_attachment(parsed):
			attachment = os.path.split(get_attachment(parsed))[1]
			attach = u"<img src='paper-clip.png'/> {0}".format(attachment)
		return open('html.html').read().replace("<!--RECIPIENTS-->", ", ".join(recips)).replace("<!--SUBJECT-->", subject).replace("<!--BODY-->", body).replace("<!--ATTACH-->", attach)

def run(parsed):
		import json
		recips = get_emails(parsed)
		subject = parsed.get('~subject', '')
		body = parsed.get('~message', '')
		attach = get_attachment(parsed)
		prefs = json.loads(open("preferences.json").read())
		
		client = prefs.get('client', 'mail.app')
		if client == 'mail.app':
			from send_mail import send_mail
			send_mail(recips, subject, body, attach)
		elif client == 'gmail':
			import gmail
			gmail.open(recips, subject, body)

