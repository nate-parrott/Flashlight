#!/usr/bin/python

import os
import urllib

import pasteboard

def results(fields, original_query):
    omni_title = fields.get('~omnifocusTitle', '').encode('utf8')
    omni_note = fields.get('~omnifocusNote', '').encode('utf8')
    omni_paste = fields.get('~omnifocusPaste', '').encode('utf8')

    if omni_paste:
        omni_title = omni_paste
        omni_note = pasteboard.get_text()

    omni_url = "omnifocus:///add?name={title}&note={note}".format(
        title=urllib.quote(omni_title),
        note=urllib.quote(omni_note)
    )

    html_template = '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset='utf-8'/>
        <style>
        html, body {
            margin: 0;
            width: 100%;
            height: 100%;
            font-family: "HelveticaNeue-Light", "Helvetica Neue Light", "Helvetica Neue", Helvetica, Arial;
            line-height: 1.2;
        }
        body {
            padding-top: 20px;
        }
        h3 {
            font-size: 30px;
            font-weight: 500;
            line-height: 1.1;
            color: #333;
        }
        h3 > small {
            font-size: 65%;
            font-weight: 400;
            line-height: 1;
            color: #777;
        }
        .text-purple {
            color: #8e44ad;
        }
        .text-muted {
            color: #777;
        }
        .panel {
            margin-bottom: 20px;
            background-color: #fff;
            border: 1px solid transparent;
            border-radius: 4px;
            -webkit-box-shadow: 0 1px 1px rgba(0,0,0,.05);
            box-shadow: 0 1px 1px rgba(0,0,0,.05);
        }
        .panel-default {
            border-color: #ddd;
        }
        .panel-body {
            padding: 15px;
        }
        .panel-body > p {
            white-space: pre-wrap;
        }
        .container {
            padding-right: 15px;
            padding-left: 15px;
            margin-right: auto;
            margin-left: auto;
            width: 300px;
        }
        </style>
    </head>
    <body class='<!--APPEARANCE-->'>
        <div class="container">
            <div class="panel">
                <div class="panel-body">
                    <h3 class="text-purple"><!--TITLE--></h3>
                    <p class="text-muted"><!--NOTE--></p>
                </div>
            </div>
        </div>
    </body>
    </html>
    '''

    html_output = (
        html_template
        .replace("<!--TITLE-->", omni_title)
        .replace("<!--NOTE-->", omni_note)
    )

    return {
        "title": "Add to OmniFocus inbox",
        "run_args": [omni_url],
        "webview_transparent_background": True,
        "html": html_output
    }

def run(url):
    import subprocess
    command = 'open "{url}"'.format(url=url)
    subprocess.call([command], shell=True)
