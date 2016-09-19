from __future__ import unicode_literals
import json
import urllib

import i18n
import hashlib
import os

def copy_to_clipboard(hashStr):
  command = 'printf ' + hashStr.strip() + '| pbcopy'
  os.system(command)

def build_html(hashStr):

  html = """
    <html>
    <head>
        <style>
            body{
                padding: 20px;
                font-family: 'Helvetica Neue';
                line-height: 1.4;
                background: #EEE;
                text-align: center;
                font-weight: 300;
            }
            .msg {
              font-size: 20px;
              color: #333;
            }
            p {
              color: #999;
              font-size: 18px;
            }
        </style>
    </head>
    <body>
        <div class="msg">{{hashStr}}</div>
        <p>Hit 'return' to copy.</p>
    </body>
    </html>
  """

  html = html.replace("{{hashStr}}", hashStr)
  return html

def results(fields, original_query):

  md5_str = hashlib.md5(fields['~str'].encode('utf-8')).hexdigest()
  html = "<h1>{0}</h1>".format(md5_str)

  return {
      "title": "md5",
      "run_args": [md5_str],  # ignore for now,
      "html": build_html(md5_str)
  }

def run(hashStr):
  copy_to_clipboard(hashStr)
