# -*- coding: utf-8 -*-

from __future__ import unicode_literals

import i18n


locations = {
    'chiba': 'chiba',
    'hyogo': 'hyogo',
    'ibaraki': 'ibaraki',
    'kyoto': 'kyoto',
    'osaka': 'osaka',
    'roppongi': 'roppongi',
    'shizuoka': 'shizuoka',
    'tokyo': 'tokyo',
    'wakayama': 'wakayama',
    '千葉': 'chiba',
    '兵庫': 'hyogo',
    '茨城': 'ibaraki',
    '京都': 'kyoto',
    '大阪': 'osaka',
    '六本木': 'roppongi',
    '静岡': 'shizuoka',
    '東京': 'tokyo',
    '和歌山': 'wakayama'
}


def results(parsed, original_query):
    if '~location' not in parsed:
        return

    location = parsed['~location'].lower()
    keys = list(filter(lambda l: l.startswith(location), locations.keys()))

    if len(keys) == 1:
        location = locations[keys[0]]
        url = 'http://sx9.jp/weather/{0}.html'.format(location)
        html = """
        <script>
        setTimeout(function () {
            window.location = '""" + url + """';
        }, 500);
        </script>
        """
        return {
            "title": i18n.localstr("Ninetan @{0}").format(
                i18n.localstr(location.capitalize())),
            "run_args": [url],
            "html": html,
            "webview_links_open_in_browser": True
        }
    else:
        return {
            "title": i18n.localstr("Ninetan location not found"),
            "run_args": [None]
        }


def run(url):
    if url is not None:
        import os
        os.system("open {0}".format(url))
