import urllib, json

def results(parsed, original_query):
    search_specs = [
         ["search deviantART", "~deviantart", "http://www.deviantart.com/browse/all/?qh=&section=&global=1&q="],
         ["searchdeviant", "~deviantart", "http://www.deviantart.com/browse/all/?qh=&section=&global=1&q="],
         ["deviantART", "~deviantart", "http://www.deviantart.com/browse/all/?qh=&section=&global=1&q="],
         ["deviant", "~deviantart", "http://www.deviantart.com/browse/all/?qh=&section=&global=1&q="],
         ["deviant TAG", "~deviant-tag", "https://www.deviantart.com/tag/"],
         ["deviant ALL", "~deviant-all", "http://www.deviantart.com/browse/all/?qh=&section=&global=1&q="],
         ["deviant Digital", "~deviant-digital", "http://www.deviantart.com/browse/all/digitalart/?order=9&q="],
         ["deviant Traditional", "~deviant-traditional", "http://www.deviantart.com/browse/all/traditional/?order=9&q="],
         ["deviant Photog", "~deviant-photog", "http://www.deviantart.com/browse/all/photography/?order=9&q="],
         ["deviant Artisan", "~deviant-artisan", "http://www.deviantart.com/browse/all/artisan/?order=9&q="],
         ["deviant Lit", "~deviant-lit", "http://www.deviantart.com/browse/all/literature/?order=9&q="],
         ["deviant Film", "~deviant-film", "http://www.deviantart.com/browse/all/film/?order=9&q="],
         ["deviant MotionBooks", "~deviant-motionbooks", "http://www.deviantart.com/browse/all/motionbooks/?order=9&q="],
         ["deviant Flash", "~deviant-flash", "http://www.deviantart.com/browse/all/flash/?order=9&q="],
         ["deviant Designs", "~deviant-designs", "http://www.deviantart.com/browse/all/designs/?order=9&q="],
         ["deviant Customize", "~deviant-customize", "http://www.deviantart.com/browse/all/customization/?order=9&q="],
         ["deviant Cartoons", "~deviant-cartoons", "http://www.deviantart.com/browse/all/cartoons/?order=9&q="],
         ["deviant Manga", "~deviant-manga", "http://www.deviantart.com/browse/all/manga/?order=9&q="],
         ["deviant Anthro", "~deviant-anthro", "http://www.deviantart.com/browse/all/anthro/?order=9&q="],
         ["deviant Fanart", "~deviant-fanart", "http://www.deviantart.com/browse/all/fanart/?order=9&q="],
         ["deviant Resources", "~deviant-resources", "http://www.deviantart.com/browse/all/resources/?order=9&q="]
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
