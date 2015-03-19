import re

def __escape(s, quoted=u'\'"\\', escape=u'\\'):
    return re.sub(
            u'[%s]' % re.escape(quoted),
            lambda mo: escape + mo.group(),
            s)

def results(fields, original_query):
    search_specs = [
        ["zeal", "~query", "~docset"]
    ]
    for name, key, docset in search_specs:
        if key in fields:
            query = fields[key]
            if docset in fields:
                docset = fields[docset]
                search_query="{0}:{1}".format(__escape(docset), __escape(query))
                return {
                    "title": "Zeal: Search in {0} for '{1}'".format(docset, query),
                    "run_args": [search_query],
                }
            else:
                search_query = __escape(query)
                return {
                    "title": "Zeal: Search for '{0}'".format(query),
                    "run_args": [search_query],
                }


def run(url):
    import os
    for fpath in [os.path.expanduser("~/Applications/zeal.app"), "/Applications/zeal.app"]:
        if os.path.exists(fpath + "/Contents/MacOS/zeal"):
            import subprocess, pipes
            pid = subprocess.Popen([fpath + '/Contents/MacOS/zeal', '--query={0}'.format(pipes.quote(url))], stdout=subprocess.PIPE, stderr=subprocess.PIPE, stdin=subprocess.PIPE)
            return

