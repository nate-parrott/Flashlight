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
        "html": open(i18n.find_localized_path("mehrtanken.html")).read().replace("SEARCHQUERY", parsed[query]).replace("FUELSETTING",benzin).replace("light-mode", "dark-mode" if dark_mode() else "light-mode")
    }