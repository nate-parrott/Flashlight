
def results(parsed, original_query):
    message = parsed['~message']
    return {
        "title": "Hex '{0}' = '{1}' decimal".format(message,int(message,16)),
        "run_args": [message] # ignore for now
            }

def run(message):
    # import os
    # os.system('open spotify:search:"{0}"'.format(message))
    pass

if __name__ == '__main__':
    # results()
    pass