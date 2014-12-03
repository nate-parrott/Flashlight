import urllib, json, i18n

def dark_mode():
    import Foundation
    return Foundation.NSUserDefaults.standardUserDefaults().persistentDomainForName_(Foundation.NSGlobalDomain).objectForKey_("AppleInterfaceStyle") == "Dark"

def results(parsed, original_query):
	benzine = "yes"
	query = "~dieselquery"
	
	if(parsed.get('~benzinequery', "nobenzin") != "nobenzin"):
 		if parsed["~benzinequery"]:
	 		benzine = "benzine"
	 		query = "~benzinequery"
		elif parsed["~dieselquery"]:
	 		benzine = "diesel"
	elif parsed["~dieselquery"]:
	 	benzine = "diesel"

 	title = i18n.localstr("Gas Price for '{0}'").format(parsed[query])
	return {

        "title": title,
        "html": open(i18n.find_localized_path("mehrtanken.html")).read().replace("SEARCHQUERY", parsed[query]).replace("FUELSETTING",benzine).replace("light-mode", "dark-mode" if dark_mode() else "light-mode"),
        "webview_transparent_background": True
    }