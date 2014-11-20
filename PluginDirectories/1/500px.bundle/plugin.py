import urllib, json

def results(parsed, original_query):
    search_specs = [
         ["search 500px", "~500px", "https://500px.com/search?utf8=%E2%9C%93&type=photos&category=All&order=score&license_type=-1&q="],
         ["search500", "~500px", "https://500px.com/search?utf8=%E2%9C%93&type=photos&category=All&order=score&license_type=-1&q="],
         ["500px", "~500px", "https://500px.com/search?utf8=%E2%9C%93&type=photos&category=All&order=score&license_type=-1&q="],
         ["500", "~500px", "https://500px.com/search?utf8=%E2%9C%93&type=photos&category=All&order=score&license_type=-1&q="],
         ["500px Abstract", "~500px-abstract", "https://500px.com/search?utf8=%E2%9C%93&type=photos&category=Abstract&order=score&license_type=-1&q="],
         ["500px Animals", "~500px-animals", "https://500px.com/search?utf8=%E2%9C%93&type=photos&category=Animals&order=score&license_type=-1&q="],
         ["500px Black & White", "~500px-black-and-white", "https://500px.com/search?utf8=%E2%9C%93&type=photos&category=Black+and+White&order=score&license_type=-1&q="],
         ["500px Celebrities", "~500px-celebrities", "https://500px.com/search?utf8=%E2%9C%93&type=photos&category=Celebrities&order=score&license_type=-1&q="],
         ["500px City & Architecture", "~500px-architecture", "https://500px.com/search?utf8=%E2%9C%93&type=photos&category=City+&+Architecture&order=score&license_type=-1&q="],
         ["500px Commercial", "~500px-commercial", "https://500px.com/search?utf8=%E2%9C%93&type=photos&category=Commercial&order=score&license_type=-1&q="],
         ["500px Concert", "~500px-concert", "https://500px.com/search?utf8=%E2%9C%93&type=photos&category=Concert&order=score&license_type=-1&q="],
         ["500px Family", "~500px-family", "https://500px.com/search?utf8=%E2%9C%93&type=photos&category=Family&order=score&license_type=-1&q="],
         ["500px Fashion", "~500px-fashion", "https://500px.com/search?utf8=%E2%9C%93&type=photos&category=Fashion&order=score&license_type=-1&q="],
         ["500px Film", "~500px-film", "https://500px.com/search?utf8=%E2%9C%93&type=photos&category=Film&order=score&license_type=-1&q="],
         ["500px Fine Art", "~500px-fine-art", "https://500px.com/search?utf8=%E2%9C%93&type=photos&category=Fine+Art&order=score&license_type=-1&q="],
         ["500px Food", "~500px-food", "https://500px.com/search?utf8=%E2%9C%93&type=photos&category=Food&order=score&license_type=-1&q="],
         ["500px Journalism", "~500px-journalism", "https://500px.com/search?utf8=%E2%9C%93&type=photos&category=Journalism&order=score&license_type=-1&q="],
         ["500px Landscapes", "~500px-landscapes", "https://500px.com/search?utf8=%E2%9C%93&type=photos&category=Landscapes&order=score&license_type=-1&q="],
         ["500px Macro", "~500px-macro", "https://500px.com/search?utf8=%E2%9C%93&type=photos&category=Macro&order=score&license_type=-1&q="],
         ["500px Nature", "~500px-nature", "https://500px.com/search?utf8=%E2%9C%93&type=photos&category=Nature&order=score&license_type=-1&q="],
         ["500px Nude", "~500px-nude", "https://500px.com/search?utf8=%E2%9C%93&type=photos&category=Nude&order=score&license_type=-1&q="],
         ["500px People", "~500px-people", "https://500px.com/search?utf8=%E2%9C%93&type=photos&category=People&order=score&license_type=-1&q="],
         ["500px Performing Arts", "~500px-performing-arts", "https://500px.com/search?utf8=%E2%9C%93&type=photos&category=Performing+Arts&order=score&license_type=-1&q="],
         ["500px Sport", "~500px-sport", "https://500px.com/search?utf8=%E2%9C%93&type=photos&category=Sport&order=score&license_type=-1&q="],
         ["500px Still Life", "~500px-still-life", "https://500px.com/search?utf8=%E2%9C%93&type=photos&category=Still+Life&order=score&license_type=-1&q="],
         ["500px Street", "~500px-street", "https://500px.com/search?utf8=%E2%9C%93&type=photos&category=Street&order=score&license_type=-1&q="],
         ["500px Transportation", "~500px-transportation", "https://500px.com/search?utf8=%E2%9C%93&type=photos&category=Transportation&order=score&license_type=-1&q="],
         ["500px Travel", "~500px-travel", "https://500px.com/search?utf8=%E2%9C%93&type=photos&category=Travel&order=score&license_type=-1&q="],
         ["500px Underwater", "~500px-underwater", "https://500px.com/search?utf8=%E2%9C%93&type=photos&category=Underwater&order=score&license_type=-1&q="],
         ["500px Urban Exploration", "~500px-urban-exploration", "https://500px.com/search?utf8=%E2%9C%93&type=photos&category=Urban+Exploration&order=score&license_type=-1&q="],
         ["500px Uncategorized", "~500px-uncategorized", "https://500px.com/search?utf8=%E2%9C%93&type=photos&category=Uncategorized&order=score&license_type=-1&q="]
    ]
    for name, key, url in search_specs:
        if key in parsed:
            search_url = url + urllib.quote_plus(parsed[key])
            return {
                "title": "Search {0} for '{1}'".format(name, parsed[key]),
                "run_args": [search_url],
                "html": """
                <script>
                setTimeout(function() {
                    window.location = %s
                }, 500);
                </script>
                """%(json.dumps(search_url)),
                "webview_user_agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53",
                "webview_links_open_in_browser": True
            }

def run(url):
    import os
    os.system('open "{0}"'.format(url))
