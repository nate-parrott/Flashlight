#!/usr/bin/python

import sys, urllib, os, time, datetime

def results(parsed, original_query):
    timestamp = int(parsed.get('timestamp', time.time()))
    date = datetime.datetime.utcfromtimestamp(timestamp)
    timestring = date.strftime('%Y-%m-%d %H:%M:%S UTC')
    style = '''
    <style type="text/css">
    * {
        padding: 0;
        margin: 0;
    }
	html, body, body > div {
		margin: 0;
		width: 100%;
		height: 100%;
		font-family: "HelveticaNeue-Light", "Helvetica Neue Light", "Helvetica Neue", Helvetica, Arial, "HiraginoSansGB-W3", "Hiragino Sans GB W3";
		line-height: 1.2;
	}
    h1, h2, h3, h4, h5 {
        font-family: "HelveticaNeue-Light", "Helvetica Neue Light", "Helvetica Neue", Helvetica, Arial, "HiraginoSansGB-W6", "Hiragino Sans GB W6";
    }
	#loading, #error {
		text-align: center;
	}
	#error, #results {
		display: none;
	}
    #results {
        text-align: left;
    }
    h1 {
        font-size: 32px;
        border-bottom: #ddd 1px solid;
        padding: 0px 0px 10px 0px;
        margin: 0px 0px 10px 0px;
        color: #444;
    }
    h3 {
        font-size: 15px;
        color: #888;
    }
    div.content {
        padding: 15px;
    }
	</style>
    '''
    return {
        "title": '"%s" (%d) - Press ENTER to copy' % (timestring, timestamp),
        "html": "%s%s" % (style, "<div><div class=\"content\"><h1>%s</h1><h3>%s</h3></div></div>" % (timestamp, timestring)),
        "run_args": ['"%s" (%d)' % (timestring, timestamp)]
    }

def run(string):
    os.system('echo "{0}" | pbcopy'.format(string.replace("\"", "\\\"")))
