def results(fields, original_query):
    message = fields['~dictquery']
    return {
        "title": "Lookup '{0}' in built-in dictionary".format(message),
        "run_args": [message]  # ignore for now
    }

def run(message):
    import os
    os.system('open dict://"{0}"'.format(message))
