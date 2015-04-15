import urllib
import json
import i18n


def results(parsed, original_query):

    search_specs = [
        ["fontawesome", "~fontawesome", "http://glyphsearch.com/?query="]
    ]
    for name, key, url in search_specs:
        if key in parsed:
            localizedurl = i18n.localstr(url)
            search_url = localizedurl + urllib.quote_plus(parsed[key].encode('UTF-8'))
            title = i18n.localstr(
                "Search {0} for '{1}'").format(name, parsed[key].encode('UTF-8'))
            return {
                "title": title,
                "run_args": [search_url],
                "html": """
                <script>
                setTimeout(function() {
                    window.location = %s
                }, 300);
                </script>
                """ % (json.dumps(search_url))
            }


def run(url):
    import os
    os.system('open "{0}"'.format(url))