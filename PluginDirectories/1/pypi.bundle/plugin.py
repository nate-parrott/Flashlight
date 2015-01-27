import json
import urllib


def results(parsed, original_query):
    if '~query' not in parsed:
        return

    query = parsed['~query']

    # Query is too short
    if len(query) < 2:
        return

    # Load server settings
    with open('preferences.json') as f:
        settings = json.load(f)
    server = settings.get('server', None)

    # Set server URL
    if server == 'warehouse':
        url_template = 'https://warehouse.python.org/search/project/?q={0}'
    elif server == 'devpi':
        url_template = 'http://localhost:3141/+search?query={0}'
    else:
        url_template = 'https://pypi.python.org/pypi?:action=search&term={0}'

    url = url_template.format(urllib.quote_plus(query))
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
