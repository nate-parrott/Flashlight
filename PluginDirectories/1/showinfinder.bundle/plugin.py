import urllib, json, os
import i18n

def dark_mode():
    import Foundation
    return Foundation.NSUserDefaults.standardUserDefaults().persistentDomainForName_(Foundation.NSGlobalDomain).objectForKey_("AppleInterfaceStyle") == "Dark"

def getFiles(url):
    import glob
    url = url if(url != "/") else ""
    return glob.glob(url+'/*')

def generateHtml(list):
    color = "#E6E6E6" if dark_mode() else "#2D2D2D"
    html = '<div style="color:'+color+';">'
    html += '<br/>'.join(list)
    html += '</div>'
    return html

def results(parsed, original_query):
    url = parsed["~path"]
    os.chdir(os.path.expanduser("~"))
    if(os.path.exists(url) == False):
        url = os.path.expanduser("~")
    else:
        url = os.path.abspath(url)
    title = i18n.localstr("Open '{0}' in Finder").format(url)
    return {
        "title":title,
        "run_args": [url],
        "webview_transparent_background": True,
        "html": generateHtml(getFiles(url))
    }

def run(url):
    import subprocess
    subprocess.call(["open", "-R", url])
