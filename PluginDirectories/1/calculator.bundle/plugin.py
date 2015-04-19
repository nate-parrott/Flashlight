def results(fields, original_query):
    exp = fields["~expression"]
    html = "<h3 id=\"res\"></h3><script>document.getElementById(\"res\").innerHTML = eval({0});</script>".format(exp)
    return {
        "title": "Result: '{0}'".format(exp),
        "run_args": [exp],
        "html": html
    }

def run(exp):
    import os
    os.system('cal "{0}"'.format(exp))
