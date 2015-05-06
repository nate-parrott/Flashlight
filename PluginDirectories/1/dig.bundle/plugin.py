import urllib
def results(fields, original_query):
    for key in ["~domain"]:
        if key in fields:
            domain = fields[key]
            html = """
<script>
    setTimeout(function() {
      window.location = 'https://toolbox.googleapps.com/apps/dig/#A/%s'
    }, 500); // delay so we don't get rate-limited by doing a request after every keystroke
</script>
  """
            return {
                "title": "Dig '{0}'".format(domain),
                "run_args": [domain],
                "html": html % (urllib.quote(domain)),
                "webview_links_open_in_browser": True,
                "webview_user_agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Mobile/12A365 Safari/600.1.4",
            }

def run(message):
  import os, pipes
  os.system('open "https://toolbox.googleapps.com/apps/dig/#A/{0}"'.format(urllib.quote(message.encode('utf8'))))

