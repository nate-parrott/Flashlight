import urllib

def results(fields, original_query):
    key = "~text"
    if key in fields:
        url = "https://chart.googleapis.com/chart?chs=300x300&cht=qr&chl=" + urllib.quote(fields[key])
        return {
        "title": "QR '{0}'".format(fields[key]),
        "run_args": [url],
        "html": '<img src="{0}">'.format(url),
        }

def run(url):
  import os
  os.system('open "{0}"'.format(url))

