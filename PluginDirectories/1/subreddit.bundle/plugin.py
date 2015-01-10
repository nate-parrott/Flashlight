def results(fields, original_query):
    message = fields['~message']
    return {
            "title": "Open r/{0}".format(message),
            "run_args": [message],
            }

def run(message):
    import webbrowser
    webbrowser.open("https://reddit.com/r/{0}".format(message))
