# -*- coding: utf-8 -*-

from __future__ import unicode_literals

import i18n


open_airdrop_script = """function run() {
    finder = Application('Finder');
    finder.activate();
    delay(1);

    event = Application('System Events');
    event.keystroke('R', {using: ['command down', 'shift down']});
}"""

html_template = """
<html>
    <body style="margin: 0">
        <img src="{0}" style="display: block; margin: 5% auto; height: 90%;">
    </body>
</html>
"""


def results(parsed, original_query):
    icon_file = i18n.find_localized_path("Icon.png")
    return {
        "title": i18n.localstr("Open AirDrop"),
        "run_args": [],
        "html": html_template.format(icon_file),
        "webview_transparent_background": True
    }


def run():
    import subprocess
    osa = subprocess.Popen(['osascript', '-l', 'JavaScript', '-'],
                           stdin=subprocess.PIPE,
                           stdout=subprocess.PIPE)
    osa.communicate(open_airdrop_script.encode('utf-8'))
