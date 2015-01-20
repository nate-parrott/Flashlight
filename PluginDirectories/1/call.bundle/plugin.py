def results(fields, original_query):
    digit = fields['~digit']

    if 'facetime' in original_query:
        is_facetime = True
        title = 'Facetime'
    else:
        is_facetime = False
        title = 'Call'

    return {
        "title": "{0} '{1}'".format(title, digit),
        "run_args": [digit, is_facetime]
    }

def run(digit, is_facetime):
    import os
    from applescript import asrun
    import time

    if is_facetime:
        os.popen('open facetime://{0}'.format(digit))
    else:
        os.popen('open tel://{0}'.format(digit))

    asrun("tell application \"Facetime\" to activate")
    time.sleep(2)
    asrun("tell application \"System Events\" to keystroke return")

