import urllib, json

def results(parsed, original_query):
	search_specs = [
        ["Amazon", "~amazonquery", "http://www.amazon.com/s/ref=nb_sb_noss?field-keywords="],
        ["Alibaba", "~alibabaquery", "http://m.alibaba.com/trade/search?SearchText="],
        ["AliExpress", "~aliexpressquery", "http://m.aliexpress.com/search.htm?keywords="],
        ["eBay", "~ebayquery", "http://www.ebay.com/sch/i.html?_nkw="],
        ["JD", "~jdquery", "http://m.jd.com/ware/search.action?keyword="],
        ["Taobao", "~taobaoquery", "http://s.m.taobao.com/h5?q="],
        ["YHD", "~yhdquery", "http://m.yhd.com/search/?req.keyword="],
        ["YiXun", "~yixunquery", "http://m.51buy.com/t/list/?keyword="],
        ["1688", "~ylbbquery", "http://m.1688.com/page/search.html?type=offer&keywords="]
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
