import os
import urllib

def results(parsed, original_query):
    key="~query"

    if key in parsed:
        url="http://devdocs.io/#q=" + urllib.quote(parsed[key])
        html = """
<script>
    setTimeout(function() {
      window.location = '%s'
    }, 500);
</script>
        """ % url
        return {
                "title": "Search '{0}' on devdocs.io".format(parsed[key]),
                "run_args": [url],
                "webview_links_open_in_browser": True,
                "webview_user_agent": "Mozilla/5.0 (Linux; Android 4.4.4; KYV33 Build/100.0.2a10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.135 Mobile Safari/537.36",
                "html": html,
                }


def run(str):
    os.system('open "{0}"'.format(str))
