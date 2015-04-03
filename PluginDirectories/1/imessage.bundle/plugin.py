import re

def results(parsed, original_query, obj):
		dict = {
				"title": "Send an iMessage",
				"run_args": [parsed],
				"html": html(parsed),
				"webview_transparent_background": True
		}
		return dict

def get_contact_from_recip(recip):
	if len(recip.keys()) > 0 and recip.keys()[0].startswith('@contact/'):
		return recip.values()[0]
	else:
		return None

def get_recipient_id(parsed):
	recip = parsed.get('recip', {})
	contact = get_contact_from_recip(recip)
	if contact:
		preferred_phone_labels = ["iPhone", "_$!<Mobile>!$_", "_$!<Main>!$_"]
		for label in preferred_phone_labels:
			if label in contact.get('Phone', {}):
				return normalize_phone(contact['Phone'][label])
		for label, email in contact.get('Email', {}).iteritems():
			return email
	if 'email' in recip:
		return recip['email']
	if 'phone' in recip:
		return normalize_phone(recip['phone'])
	return None

def normalize_phone(num):
	drop = ' -.()'
	for c in drop:
		num = num.replace(c, '')
	if len(num) > 5 and re.match(r"^[0-9]+$", num):
		return num
	else:
		return None

def get_recipient_name(parsed):
	recip = parsed.get('recip', {})
	contact = get_contact_from_recip(recip)
	if contact and 'displayName' in contact:
		return contact['displayName']
	return get_recipient_id(parsed)

def html(parsed):
		recipients = [get_recipient_name(parsed)] if get_recipient_name(parsed) else []
		body = parsed.get('~message', '')
		# TODO: attachments
		attach = ""
		return open('html.html').read().replace("<!--RECIPIENTS-->", ", ".join(recipients)).replace("<!--BODY-->", body).replace("<!--ATTACH-->", attach)

def run(parsed):
		recip = get_recipient_id(parsed)
		if recip:
			body = parsed.get('~message', [''])
			attach = False # TODO
			from send_message import send_message
			send_message(recip, body, attach)
