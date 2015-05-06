import os

def is_valid_command(name):
    import subprocess
    whereis = subprocess.Popen(['whereis', name], stdout=subprocess.PIPE, stdin=subprocess.PIPE)
    return len(whereis.communicate("")[0]) > 0

def get_html(command):
  from getpass import getuser
  return """
  <style>
  body {
    background-color: #222;
    font-family: monospace;
    color: white;
    padding: 10px;
    font-size: large;
  }
  #hint {
    font-size: small;
    opacity: 0.7;
  }
  </style>
  <body>
  %s$ %s
  
  <div id='hint'>
  Will be run in the directory currently open in Finder.
  </div>
  </body>
  """%(getuser(), command)

def results(parsed, original_query):
    command = parsed['~command'] if parsed else original_query
    if command[0] not in '~/.' and not is_valid_command(command.split(' ')[0]):
        return None
    dict = {
        "title": "$ {0}".format(command),
        "run_args": [command],
        "html": get_html(command)
    }
    if parsed==None:
        dict['dont_force_top_hit'] = True
    return dict

def run(command):
    from applescript import asrun, asquote
    from pipes import quote
    import json

    ascript_currentdir = '''
    tell application "Finder"
         if (count of Finder windows) is not 0 then
            set currentDir to (target of front Finder window) as text
            set dir to (quoted form of POSIX path of currentDir)
        else
            set dir to "~/"
        end if
    end tell
    '''

    settings = json.load(open('preferences.json'))

    # If the app is terminal, or _not_ iTerm2
    if settings["app"] == "terminal" or settings["app"] not in ("iterm2", "iterm3"):
        ascript = ascript_currentdir + '''
        tell application "Terminal"
            activate
            do script "cd " & dir
            do script {0} in front window
        end tell
        '''.format(asquote(command))
    else:
        # iTerm 2.9+ uses "window" instead of "terminal" for applescript
        window_name = "terminal" if settings["app"] == "iterm2" else "window"
        ascript = ascript_currentdir + '''
        tell application "iTerm"
            tell (make new {1})
                    activate current session
                    launch session "Default Session"
                    tell the last session
                        write text "cd " & dir
                        write text {0}
                    end tell
            end tell
        end tell
        '''.format(asquote(command), window_name)

    asrun(ascript)
