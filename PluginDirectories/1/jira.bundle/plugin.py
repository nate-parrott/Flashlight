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
	    	search_key = '&jql=' + urllib.quote_plus("project = " + parsed[project].encode('UTF-8') + " AND text ~ \"" + parsed[key].encode('UTF-8') + "\"  ORDER BY updated DESC")
	    else:
	    	search_key = '&jql=' + urllib.quote_plus("text ~ \"" + parsed[key].encode('UTF-8') + "\"  ORDER BY updated DESC")
            search_url = host + url + basic + search_key
		
	    regexJIRA = re.compile("^ *(?P<jira>[a-zA-Z]+-\d+) *$")
	    regexPROJ = re.compile("^ *(?P<project>[a-zA-Z]{3,}):(.*)")
	    searchJIRA = regexJIRA.search(parsed[key].encode('UTF-8'))
	    searchPROJ = regexPROJ.search(parsed[key].encode('UTF-8'))
	    if searchJIRA:
		search_url = host + "/browse/" + urllib.quote_plus(searchJIRA.group(0).encode('UTF-8')) + basic
	    if searchPROJ:
		search_url = host + url + basic + "&jql=" + urllib.quote_plus("project = " + searchPROJ.group(1).encode('UTF-8') + " AND text ~ \"" + searchPROJ.group(2).encode('UTF-8') + "\"  ORDER BY updated DESC")
	    html = """
                <script>
                setTimeout(function() {
                    window.location = %s
                }, 500);
                </script>
                """ % (json.dumps(search_url))
	    if (settings.get("user","") == "") or (settings.get("password","") == "") or (settings.get("host","") == ""):
	    	html = "Please enter information in flashlight in the settings of the jira plugin first"
            title = i18n.localstr(
                "Search {0} for '{1}'").format(name, parsed[key].encode('UTF-8'))
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
