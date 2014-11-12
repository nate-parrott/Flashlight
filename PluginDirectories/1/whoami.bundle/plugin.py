
def results(parsed, original_query):
	return {
		"title": "Who am I?' (press enter)",
		"run_args": ['']
	}


def run(message):
	import getpass
	import os
	os.system('say "{0}"'.format('You are ' + getpass.getuser()))

