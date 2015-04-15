import urllib,json
def results(parsed, original_query):
    search_specs = [
         ["trakt", "~traktquery", "http://trakt.tv/search?query="]
    ]
    for name, key, url in search_specs:
        if key in parsed:
            search_url = url + urllib.quote_plus(parsed[key])
            return {
                "title": "Search {0} for '{1}'".format(name, parsed[key]),
                "run_args": [search_url]
            }

def run(url):
    import os
    os.system('open "{0}"'.format(url))
