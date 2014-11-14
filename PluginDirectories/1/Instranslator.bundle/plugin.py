lang = {
	'spanish': 'es',
	'english': 'en',
	'arab': 'ar',
	"french" : "fr",
	"german" : "de",
	'hindi' : "hi",
	'portuguese' : "pt",
}

def results(parsed, original_query):
    text = parsed['~text']
    query_language = original_query.split(" ")[-1].lower()
    lan = lang[query_language]
    html = open("translate.html").read().replace("----words----", text).replace("----lang----", lan)
    return {
        "title": "Showing {0} in {1}".format(text, query_language),
        "html": html,
    }
