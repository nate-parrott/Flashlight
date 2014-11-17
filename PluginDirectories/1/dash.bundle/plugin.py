import urllib, json

def results(parsed, original_query):
    search_specs = [
         ["DASH", "~dashquery", "~docset", "dash-plugin://"]
    ]
    for name, key, docset, url in search_specs:
        if key in parsed:
            if docset in parsed:
                search_url = url + 'keys=' + urllib.quote_plus(parsed[docset]) + '&query=' + urllib.quote_plus(parsed[key])
                return {
                    "title": "DASH: Search in {0} for '{1}'".format(parsed[docset],parsed[key]),
                    "run_args": [search_url]
                }

            else:
                search_url = url + 'query=' + urllib.quote_plus(parsed[key])
                return {
                    "title": "DASH: Search for '{0}'".format(parsed[key]),
                    "run_args": [search_url]
                }

def run(url):
    import os
    os.system('open "{0}"'.format(url))
