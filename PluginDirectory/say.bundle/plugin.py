
def results(parsed, original_query):
	return {
		"title": "Say '{0}' (press enter)".format(parsed['~message']),
		"run_args": [parsed['~message']]
	}


def run(message):
	import os
	os.system('say "{0}"'.format(message))

