import urllib, json
import i18n

def results(parsed, original_query):
  query = parsed['~iflquery']
  base = "http://www.google.com/search?&sourceid=navclient&btnI=I&q="
  url = base + urllib.quote_plus(query.encode('utf-8'))
  title = u"I'm Feeling Lucky: {0}".format(query)
  return {
      "title": title,
      "run_args": [url],
      "html": """
      <script>
      setTimeout(function() {
          window.location = <!--URL-->;
      }, 500);
      </script>
      
  		<style>
  		html, body {
  			margin: 0px;
  			width: 100%;
  			height: 100%;
        color: #333;
  			font-family: "HelveticaNeue";
  		}
  		body > #centered {
  			display: table;
  			width: 100%;
  			height: 100%
  		}
  		body > #centered > div {
  			display: table-cell;
  			vertical-align: middle;
  			text-align: center;
  			font-size: x-large;
  			line-height: 1.1;
  			padding: 30px;
  		}
  		</style>
  		<body>
  		<div id='centered'>
  		<div>
  		  Loading first search result...
  		</div>
  		</div>
  		</body>
      
      
      """.replace('<!--URL-->', json.dumps(url)),
      "webview_user_agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53",
      "webview_links_open_in_browser": True
  }

def run(url):
    import os
    os.system('open "{0}"'.format(url))
