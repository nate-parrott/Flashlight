import os, pipes, urllib

def open(recipients, subject, body):
	args = [
		("view", "cm"),
		("fs", "1"),
		("to", (u",".join(recipients)).encode('utf-8')),
		("su", subject.encode('utf-8')),
		("body", body.encode('utf-8'))
		# ("bcc", "")
	]
	
	url = "https://mail.google.com/mail/?" + urllib.urlencode(args)
	print url
	os.system("open {0}".format(pipes.quote(url)))

if __name__ == '__main__':
	open(["someone@example.com", "someone2@example.com"], "SUBJECT", "hello world")
