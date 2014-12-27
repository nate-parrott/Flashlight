import urllib

def results(parsed, original_query):
    if '~query' not in parsed:
        return

    query = parsed['~query']
    url = 'https://pypi.python.org/pypi?:action=search&term={0}'.format(
            urllib.quote_plus(query))
    html = """
    <script>
    setTimeout(function () {
        window.location = '""" + url + """';
    }, 500);
    </script>
    """

    return {
        "title": "Search PyPI for '{0}'".format(query),
        "run_args": [url],
        "html": html,
        "webview_links_open_in_browser": True
    }

def run(url):
    import os
    os.system('open "{0}"'.format(url))
