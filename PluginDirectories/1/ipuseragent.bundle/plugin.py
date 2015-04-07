import i18n
import socket

def dark_mode():
    import Foundation
    return Foundation.NSUserDefaults.standardUserDefaults().persistentDomainForName_(Foundation.NSGlobalDomain).objectForKey_("AppleInterfaceStyle") == "Dark"

def results(parsed, original):
  import json
  return {
    "title": i18n.localstr("External IP Address / Useragent"),
    "html": open(i18n.find_localized_path("ipuseragent.html")).read()
	    .replace("light-mode", "dark-mode" if dark_mode() else "light-mode")
	    .replace("#{local-ip}", socket.gethostbyname(socket.gethostname())),
    "pass_result_of_output_function_as_first_run_arg": True,
    "webview_transparent_background": True
  }
