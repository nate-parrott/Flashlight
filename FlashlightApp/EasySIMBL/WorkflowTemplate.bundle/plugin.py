import urllib, json

def results(parsed, original_query):
    return {
        "title": json.loads(open("info.json").read())['displayName'],
        "run_args": [parsed]
    }

def run(parsed):
    import os, pipes
    words = ["automator"]
    for key, val in parsed.iteritems():
        words.append("-D {0}={1}".format(key, pipes.quote(val)))
    words.append("workflow.workflow")
    os.system(" ".join(words))
