import urllib, json, os
import i18n

def dark_mode():
    import Foundation
    return Foundation.NSUserDefaults.standardUserDefaults().persistentDomainForName_(Foundation.NSGlobalDomain).objectForKey_("AppleInterfaceStyle") == "Dark"

import fnmatch
import os
import re

def complete_path(partial_path):
    if os.path.exists(partial_path):
        return partial_path
    dir, partial_filename = os.path.split(partial_path)
    if os.path.exists(dir):
        for file in os.listdir(dir):
            if file.lower().startswith(partial_filename.lower()):
                path = os.path.join(dir, file)
                return path
    return None

def getFiles(url):
    import glob
    url = url if(url != "/") else ""
    return glob.glob(url+'/*')

def generateHtml(list):
    import pipes
    items = "\n".join(["""<div onClick='flashlight.bash("open \\"{0}\\"")'>{0}</div>""".format(path) for path in list])
    
    color = "#E6E6E6" if dark_mode() else "#2D2D2D"
    html = """
    <style>
    body {
        color: <!--COLOR-->;
        font-family: "HelveticaNeue-Light";
    }
    #list {
        padding: 5px;
        padding-right: 20px;
    }
    #list > div {
        border-bottom: 1px solid rgba(120,120,120,0.5);
        padding: 5px;
        cursor: default;
    }
    </style>
    <body>
    <div id='list'>
        <!--ITEMS-->
    </div>
    </body>
    """.replace("<!--COLOR-->", color).replace("<!--ITEMS-->", items)
    return html

def results(parsed, original_query):
    path = parsed["~path"]
    if path.lower() in original_query.lower():
        index = original_query.lower().index(path.lower())
        path = original_query[index:index+len(path)]
    path = os.path.abspath(os.path.expanduser(path))
    path = complete_path(path)
    if not os.path.exists(path):
        return None
    title = i18n.localstr("finder {0}").format(path)
    return {
        "title":title,
        "run_args": [path],
        "webview_transparent_background": True,
        "html": generateHtml(getFiles(path))
    }

def run(url):
    import subprocess
    if os.path.isdir(url):
        subprocess.call(["open", url])
    else:
        subprocess.call(["open", "-R", url])
