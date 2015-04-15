
def results(fields, original_query):
    message = fields['~message']
    return {
        "title": "{0} hidden files".format(message),
        "run_args": [message]
    }

def run(message):
    import os
    cmd = "NO"
    if ('show' == message):
        cmd = "YES"
    os.system("osascript -e 'do shell script \"defaults write com.apple.finder AppleShowAllFiles " + cmd + "\"'")
    os.system("osascript -e 'tell app \"Finder\" to quit'")
    os.system("osascript -e 'tell app \"Finder\" to activate'")
 
