import urllib, json

def results(parsed, original_query):
    import datetime
    html = u"""
    <html>
    <head>
    <style>
    html, body, #container {
      margin: 0px;
      width: 100%;
      height: 100%;
      font-family: sans-serif;
    }
    #container {
      display: table;
    }
    #container > div {
      display: table-cell;
      text-align: center;
      vertical-align: middle;
    }
    #reminder {
      display: inline-table;
      width: 80%;
      background-color: #eee;
      box-shadow: 0px 2px 5px rgba(60, 60, 60, 0.5);
      border-radius: 4px;
      padding: 5px;
      line-height: 1.2;
    }
    #reminder > * {
      display: table-cell;
      vertical-align: middle;
      text-align: left;
      padding: 1px;
    }
    #date {
      color: #c44;
      font-weight: bold;
    }
    #date:empty {
      display: none;
    }
    
    #check {
      display: block;
      margin: auto;
      width: 20px;
      height: 20px;
      border: 2px solid gray;
      border-radius: 50%;
    }
    
    h3 {
      font-weight: normal;
      margin-bottom: 0;
    }
    
    #meta {
      opacity: 0.7;
      font-size: small;
    }
    #meta > div {
      margin-top: 3px;
    }
    
    </style>
    </head>
    
    <body>
    <div id='container'>
      <div>
        <div id='reminder'>
          <div>
            <div id='check'></div>
          </div>
          <div style='width: auto'>
            <h3><!--MESSAGE--></h3>
            <div id='meta'>
              <div id='date'><!--DATE--></div> 
              <div>Press enter to create</div>
            </div>
          </div>
        </div>
      </div>
    </div>
    </body>
    </html>
    """.replace("<!--MESSAGE-->", parsed['~message'])
    if '@date' in parsed:
      time = datetime.datetime.fromtimestamp(int(parsed['@date']['timestamp']))
      time_str = time.strftime("%a, %b %d at %I:%M %p")
      html = html.replace("<!--DATE-->", time_str)
    return {
        "title": json.loads(open("info.json").read())['displayName'],
        "run_args": [parsed],
        "html": html,
        "webview_transparent_background": True
    }

def run(parsed):
    from applescript import asrun
    get_date = ''
    set_date = ''
    if '@date' in parsed:
      get_date = 'set theDueDate to epoch2datetime("{0}")'.format(parsed['@date']['timestamp'])
      set_date = "set due date of newReminder to theDueDate"
    script = """
    on epoch2datetime(epochseconds)
    	set myshell1 to "date -r "
    	set myshell2 to " \\"+%m/%d/%Y %I:%M:%S %p\\""
    	log (myshell1 & epochseconds & myshell2)
    	set theDatetime to do shell script (myshell1 & epochseconds & myshell2)
    	return date theDatetime
    end epoch2datetime

    {0}

    tell application "Reminders"
    	set newReminder to make new reminder
    	set name of newReminder to "{1}"
      {2}
    	display notification "Created reminder" with title "Flashlight"
    end tell
    
    """.format(get_date, parsed['~message'], set_date)
    print script
    asrun(script)
