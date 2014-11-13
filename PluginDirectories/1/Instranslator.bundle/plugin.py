def results(parsed, original_query):
	text = parsed['~text']
	html = open("translate.html").read().replace("----words----", text)
	return {
		"title": "Searching meaning of {0} ...".format(parsed['~text']),
		"html": html,
	}
