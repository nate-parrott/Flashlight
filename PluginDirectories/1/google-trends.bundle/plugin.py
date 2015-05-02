import urllib
def results(fields, original_query):
    for key in ["~keyword"]:
        if key in fields:
            keyword = fields[key].encode('utf8')
            url = "https://www.google.co.jp/trends/explore#q={0}&cmpt=q&tz=".format(urllib.quote(keyword))
            html = """
<script>
    setTimeout(function() {
      window.location = '%s'
    }, 500);
</script>
            """ % url
            return {
                "title": "Search '{0}' on Google Trends".format(keyword),
                "run_args": [url],
                "webview_links_open_in_browser": True,
                "webview_user_agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A403 Safari/8536.25",
                "html": html
            }

def run(url):
    import os, pipes
    os.system('open "{0}"'.format(url))

