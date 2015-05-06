import urllib
import json
import i18n
import re

settings = json.load(open('preferences.json'))

def results(parsed, original_query):

    search_specs = [
        ["jira", "~query", "~project", "/issues/"]
    ]
    for name, key, project, url in search_specs:
        if key in parsed:
	    user = urllib.quote_plus(settings.get("user").encode('UTF-8'))
	    password = urllib.quote_plus(settings.get("password").encode('UTF-8'))
	    basic = '?os_authType=basic'
	    host = settings.get("host").replace("://", "://" + user + ":" + password + "@")
	    if project in parsed:
	    	search_key = '&jql=' + urllib.quote_plus("project = " + parsed[project].encode('UTF-8') + " AND text ~ \"" + parsed[key].encode('ascii','xmlcharrefreplace') + "\"  ORDER BY updated DESC")
	    else:
	    	search_key = '&jql=' + urllib.quote_plus("text ~ \"" + parsed[key].encode('ascii','xmlcharrefreplace') + "\"  ORDER BY updated DESC")
            search_url = host + url + basic + search_key
		
	    regexJIRA = re.compile("^ *(?P<jira>[a-zA-Z]+-\d+) *$")
	    regexPROJ1 = re.compile("^ *(?P<project>[a-zA-Z]{3,}):(.*)")
	    regexPROJ2 = re.compile("^ *(?P<project>[a-zA-Z]{3,}): *$")
	    searchJIRA = regexJIRA.search(parsed[key].encode('UTF-8'))
	    searchPROJ1 = regexPROJ1.search(parsed[key].encode('UTF-8'))
	    searchPROJ2 = regexPROJ2.search(parsed[key].encode('UTF-8'))
	    if searchJIRA:
		search_url = host + "/browse/" + urllib.quote_plus(searchJIRA.group(0).encode('UTF-8')) + basic
	    if searchPROJ1:
		search_url = host + url + basic + "&jql=" + urllib.quote_plus("project = " + searchPROJ1.group(1).encode('UTF-8') + " AND text ~ \"" + searchPROJ1.group(2).encode('ascii','xmlcharrefreplace') + "\"  ORDER BY updated DESC")
	    if searchPROJ2:
		search_url = host + url + basic + "&jql=" + urllib.quote_plus("project = " + searchPROJ2.group(1).encode('UTF-8') + " ORDER BY updated DESC")
	    search_url = search_url.replace("a%26%23776%3B","%C3%A4").replace("A%26%23776%3B","%C3%84").replace("o%26%23776%3B","%C3%B6").replace("O%26%23776%3B","%C3%96").replace("u%26%23776%3B","%C3%BC").replace("U%26%23776%3B","%C3%9C").replace("%26%23223%3B","%C3%9F")
	    html = """
                <script>
                setTimeout(function() {
                    window.location = %s
                }, 500);
                </script>
                """ % (json.dumps(search_url))
	    if (settings.get("user","") == "") or (settings.get("password","") == "") or (settings.get("host","") == ""):
	    	html = "Please enter user information in flashlight in the settings of the jira plugin first"
            title = i18n.localstr(
                "Search {0} for '{1}'").format(name, parsed[key])
            return {
                "title": title,
                "run_args": [search_url],
                "html": html,
                "webview_user_agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53",
                "webview_links_open_in_browser": True
            }


def run(url):
    import os
    os.system('open "{0}"'.format(url))
