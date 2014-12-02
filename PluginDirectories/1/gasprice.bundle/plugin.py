import urllib, json, i18n

def dark_mode():
    import Foundation
    return Foundation.NSUserDefaults.standardUserDefaults().persistentDomainForName_(Foundation.NSGlobalDomain).objectForKey_("AppleInterfaceStyle") == "Dark"

def results(parsed, original_query):
	benzin = "yes"
	query = "~dieselquery"
	
	if(parsed.get('~benzinquery', "nobenzin") != "nobenzin"):
 		if parsed["~benzinquery"]:
	 		benzin = "benzin"
	 		query = "~benzinquery"
		elif parsed["~dieselquery"]:
	 		benzin = "diesel"
	elif parsed["~dieselquery"]:
	 	benzin = "diesel"

 	title = i18n.localstr("Gas Price for '{0}'").format(parsed[query])
	return {

        "title": title,
        "html": open(i18n.find_localized_path("mehrtanken.html")).read().replace("SEARCHQUERY", parsed[query]).replace("FUELSETTING",benzin).replace("light-mode", "dark-mode" if dark_mode() else "light-mode"),
        "webview_user_agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53",
        "webview_links_open_in_browser": True
    }