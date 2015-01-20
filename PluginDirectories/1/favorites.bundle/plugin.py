import urllib, json, i18n

def results(parsed, original_query):
    settings = json.load(open('preferences.json'))
    shortcuts = settings["shortcuts"]
    count = len(shortcuts)
    for i in range(count): 
        url = shortcuts[i]["url"]
        shortcut = shortcuts[i]["shortcut"]
        if shortcut.lower() == original_query.lower():
            if url.startswith('http') == False: 
                if not '//' in url: 
                    url = "http://" + url
            return {
                "title": "Go to " + shortcut,
                "run_args": [url]
            }


def run(url):
    import os
    os.system('open "{0}"'.format(url))
