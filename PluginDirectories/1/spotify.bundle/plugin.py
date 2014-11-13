
def results(parsed, original_query):
    return {
    "title": "Spotify '{0}' (press enter)".format(parsed['~search']),
    "run_args": [parsed['~search']]
    }


def run(message):
    import os
    os.system('open spotify:search:"{0}"'.format(message))

