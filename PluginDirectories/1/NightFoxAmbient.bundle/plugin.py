def results(fields, original_query):
    import cgi, json
    message = fields['~message']
    message = message.encode('utf8')
    
    data = json.load(open('preferences.json'))
    isDone = True
    if "CK" not in data or "CS" not in data or "AT" not in data or "AS" not in data :
        isDone = False

    if isDone == True:
            html = u"""<!DOCTYPE html><html>
            <head>
            
            <style>
            body {
            background-color: #E7F2F4;
            font-family: "Helvetica Neue";
            line-height: 1.3;
            margin: 100;
            
            }
            
            html, body {
            height: 100%;
            }
            
            #field {
            border-color:#cccccc;
            border-width:1px;
            border-style:solid;
            border-radius: 5px;
            background-color: #FFFFFF;
            box-sizing: border-box;
            padding: 10px;
            padding-bottom: 50px;
            outline: none;
            }
            
            #field:empty:before {
            content: "What are you doing?";
            opacity: 0.5;
            }
            
            #save {
            background-color: #C7E2E4;
            margin: 10px;
            border-radius: 5px;
            color: #87A2A4;
            border-top: 0.5px solid rgba(0,0,0,0.75);
            padding: 10px;
            text-align: center;
            text-transform: uppercase;
            font-weight: bold;
            font-size: small;
            position: fixed;
            right: 0;
            cursor: default;
            }
            </style>
            
            <script>
            function output() {
            return document.getElementById("field").innerText;
            }
            </script>
            
            </head>
            <body>
            <div id='field' contentEditable><!--CONTENT--></div>
            <div id='save' onClick="flashlight.invoke()">
            update
            </div>
            
            </body>
            </html>""".replace("<!--CONTENT-->", unicode(message, 'utf-8'))
    else:
        html = u"""<!DOCTYPE html><html>
            <head>
            
            <style>
            body {
            background-image: url(help.png);
            background-size:100%;
            }
            </style>
            
            </head>
            <body>
            </body>
            </html>"""
    return {
        "title": "update twitter",
        "run_args": [message],
        "html": html
    }

def run(message):
    import os, pipes, json
    from requests_oauthlib import OAuth1Session
    from applescript import asrun, asquote
    
    message = message.encode('utf8')
    
    data = json.load(open('preferences.json'))
    
    if "CK" not in data or "CS" not in data or "AT" not in data or "AS" not in data :
        _alert("!!!Error!!!","Configure FlashLight settings.\n FlashLight>Installed>AppName>Settings")
        return
    
    CK = data["CK"]
    CS = data["CS"]
    AT = data["AT"]
    AS = data["AS"]

    if CK == "" or CS == "" or AT == "" or AS == "":
        _alert("Error","Configure FlashLight settings.\n FlashLight>Installed>AppName>Settings")
        return

    url = "https://api.twitter.com/1.1/statuses/update.json"
    
    params = {"status": "{0}".format(message)}
    
    twitter = OAuth1Session(CK, CS, AT, AS)
    
    req = twitter.post(url, params = params)
    if req.status_code == 200:
        _alert("Tweet success!",message)
    else:
        _alert("Tweet faild","Error")

def _alert(title,message):
    from applescript import asrun, asquote
    script = u"""tell application "Finder"
    display notification <!--MESSAGE--> with title <!--TITLE-->
    end tell""".encode('utf8').replace("<!--TITLE-->",asquote(title)).replace("<!--MESSAGE-->", asquote(message))
    asrun(script)