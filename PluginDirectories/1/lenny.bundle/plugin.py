import os
import i18n
import fileinput
import optparse


"""def run(cmd):
    os.system(cmd)"""


def results(parsed, original_query):
    with open('lenny.html','r') as f_open:
        html = f_open.read()
    if ("allfaces" in parsed):
        return {
            "title": 'Le Lenny Face',
            "run_args": [],
            """ with thanks to http://www.alexdantas.net/lenny/ """
            "html": html
            
        }

    """if ('restart_command' in parsed):
        return {
            "title": i18n.localstr('Restart Mac'),
            "run_args": ["osascript -e 'tell app \"System Events\" to restart'"]
        }"""
