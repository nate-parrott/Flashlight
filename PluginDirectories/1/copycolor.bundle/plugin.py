import os

def find_format(parsed):
    for field in parsed:
        if field.startswith('format/'):
            return field[len('format/'):]
    return 'hex'

def results(parsed, query):
    format = find_format(parsed)
    return {
    "title": "Pick a color as {0}".format(format),
    "run_args": [format]
    }

def run(format):
  import subprocess, sys
  pid = subprocess.Popen([sys.executable, "pick_color.py", format], stdout=subprocess.PIPE, stderr=subprocess.PIPE, stdin=subprocess.PIPE)
