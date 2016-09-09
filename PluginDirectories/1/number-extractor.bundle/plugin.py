def appearance(): #using from emoji.bundle
    import Foundation
    dark_mode = Foundation.NSUserDefaults.standardUserDefaults().persistentDomainForName_(Foundation.NSGlobalDomain).objectForKey_("AppleInterfaceStyle") == "Dark"
    return "dark" if dark_mode else "light"

def extract_number(numbers_and_things):
  import re
  return re.sub(r"[^0-9]", '', numbers_and_things)

def make_html(number):
  #using styles found in emoji.bundle
  html = """
    <head>
    <style>
        body{
                padding: 10px 12px;
                font: 15px/1.4 'Helvetica Neue';
                font-weight: 300;
            }
            h1 {
                font-size: 20px;
                font-weight: 300;
            }
            .dark {
                color: rgb(224,224,224);
            }
            </style>
    </head>
    <body class="{{appearance}}">
        <h1> 
        {{number}}
        </h1>
    </body>
    """
  html = html.replace("{{appearance}}", appearance())
  html = html.replace("{{number}}", number)
  return html


def results(fields, original_query):
  message = fields['~message']
  return {
    "title": "Extract numbers from '{0}'".format(message),
    "run_args": [message],
    "html": make_html(extract_number(message)),
    'webview_transparent_background': True,
  }

def run(message):
  import os 
  numbers = extract_number(message)
  os.system("echo '%s' | pbcopy" % numbers) #I'm assuming this script will ONLY run in OS X
