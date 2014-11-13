def results(parsed, original_query):
	text = parsed['~text']
	html = open("translate.html").read().replace("----words----", text)
	return {
		"title": "Translate {0} to Spanish".format(parsed['~text']),
		"html": html,
	}
