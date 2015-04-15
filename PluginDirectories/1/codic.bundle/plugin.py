import urllib
def results(fields, original_query):
    search_specs = [
        ["codic", "~query", "http://codic.jp/search?q={0}"]
    ]
    for name, key, url in search_specs:
        if key in fields:
            query = fields[key].encode('UTF-8')
            search_url = url.format(urllib.quote(query))
            html = """
<script>
    setTimeout(function() {
      window.location = '%s'
    }, 500);
</script>
            """ % search_url
            return {
                "title": "Search '{0}' on codic.jp".format(query),
                "run_args": [search_url],
                "webview_links_open_in_browser": False,
            	"html": html
            }

def run(url):
    import os
    os.system('open "{0}"'.format(url))

