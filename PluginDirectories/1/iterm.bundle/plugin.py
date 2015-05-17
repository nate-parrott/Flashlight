import json, subprocess
import os

def appearance():
    import Foundation
    dark_mode = Foundation.NSUserDefaults.standardUserDefaults().persistentDomainForName_(Foundation.NSGlobalDomain).objectForKey_("AppleInterfaceStyle") == "Dark"
    return "dark" if dark_mode else "light"


def build_html(file, directories):
    html = """
    <html>
    <head>
        <style>
            * {
                box-sizing: border-box;
            }

            html, body{
                position: absolute;
                left: 0;
                right: 0;
                top: 0;
                bottom: 0;
                margin: 0;
                padding: 0;
                font: 15px/1.4 'Helvetica Neue';
                font-weight: 300;
                -webkit-user-select: none;
                overflow: hidden;
            }

            .featured {
                position: absolute;
                top: 27px;
                left: 22px;
                right: 22px;
                height: 70px;
                border-bottom: 1px solid rgb(217,217,217);
                overflow: hidden;
            }

            .featured .icon {
                display: block;
                float: left;
                width: 63px;
                height: 50px;
                background: transparent url('folder.png') no-repeat;
                background-size: cover;
                margin-right: 22px;
            }

            .featured .name {
                color: black;
                font-size: 20px;
                font-weiht: 400;
            }

            .content {
                position: absolute;
                top: 0;
                right: 0;
                left: 0;
                width: 100vw;
                bottom: 0;
                overflow-y: auto;
            }

            body.withFeatured .content {
                top: 96px;
            }

            ul {
                margin: 0;
                padding: 0;
                list-style: none;
            }

            ul li {
                position: relative;
                height: 45px;
                padding: 3px 22px;
            }

            ul li .separator {
                position: absolute;
                left: 22px; right: 22px;
                padding: 3px 0 0;
                border-bottom: 1px solid rgb(217,217,217);
                bottom: -1px;
            }

            ul li .icon {
                position: relative;
                top: 7px;
                float: left;
                width: 32px;
                height: 25px;
                margin-right: 20px;
                background: transparent url('folder.png') no-repeat;
                background-size: cover;
            }

            ul li:active, ul li:active .description {
                background: rgb(0,123, 255);
                color: white;
            }

            .name {
                text-overflow: ellipsis;
                white-space: nowrap;
                overflow: hidden;
            }

            .description {
                font-size: 12px;
                color: rgb(145, 145, 145);
                overflow: hidden;
                white-space: nowrap;
                text-overflow: ellipsis;
            }

            .dark {
                color: rgb(224,224,224);
            }

            .dark .featured {
                border-bottom: 1px solid rgb(119, 119, 119);
            }

            .dark .separator {
                border-bottom: 1px solid rgb(119,119,119);
            }

            .dark .name {
                color: rgb(224,224,224);
            }
        </style>
        <script>
            function openPath(path) {
                command = 'open -a "iTerm" {{path}}';
                flashlight.bash(command.replace(/{{path}}/g, path));
            }
        </script>
    </head>
    <body class="{{appearance}}{{has_feature}}">
        {{content}}
    </body>
    </html>
    """.replace("{{appearance}}", appearance())

    content = ''
    if file:
        html = html.replace('{{has_feature}}', ' withFeatured')
        content += """
        <div class="featured">
            <span class="icon"></span>
            <div class="name">%s</div>
            <div class="description">%s</div>
        </div>
        """ % (os.path.basename(file), os.path.dirname(file))
    else:
        html = html.replace('{{has_feature}}', '')


    content += '<div class="content"><ul>'
    for directory in directories:
        content += """
        <li onclick="openPath('%s')">
            <span class="icon"></span>
            <div class="name">%s</div>
            <div class="description">%s</div>
            <div class="separator"></div>
        </li>
        """ % (directory, os.path.basename(directory), os.path.dirname(directory)+'/')
    content += '</ul></div>'

    return html.replace("{{content}}", content)


def get_alias(name, aliases):
    for val in aliases or ():
        if val.has_key('name') and val['name'] == name:
            return val['path']


def results(params, original_query):
    query = params['~query'] if params.has_key('~query') else ''
    if len(query) < 3: query = ''
    config = json.load(open('preferences.json'))
    title = 'Open current selection with iTerm2'
    file = get_alias(query, config['aliases'])
    files = []

    if query:
        files = subprocess.check_output("mdfind 'kind:folder {{query}}'".replace('{{query}}', query), shell=True).strip()
        files = files.split('\n')[:30]
        files = filter(lambda file: len(file) and '/Library' not in file, files)
        user_home = os.getenv("HOME")
        files = map(lambda file: file.replace(user_home, '~'), files)

    if not file and len(files):
        file_to_open = files[0]
    else:
        file_to_open = file

    if not len(files):
        for val in config['aliases'] or ():
            if val.has_key('path'): files.append(val['path'])

    if file_to_open:
        title = 'Open '+ file_to_open +' in iTerm2'

    return {
        "title": title,
        'html': build_html(file, files),
        "run_args": [file_to_open],
        'webview_transparent_background': True
    }


def run(file):
    if not file: return open_finder_item()
    open_file(file)


def open_file(path):
    import subprocess
    command = 'open -a "iTerm" %s' % (path)
    subprocess.call([command], shell=True)


def open_finder_item():

    ascript = """
    set finderSelection to ""
    set theTarget to ""
    set appPath to path to application "iTerm"
    set defaultTarget to (path to home folder as alias)

    tell application "Finder"
        set finderSelection to (get selection)
        if length of finderSelection is greater than 0 then
            set theTarget to finderSelection
        else
            try
                set theTarget to (folder of the front window as alias)
            on error
                set theTarget to defaultTarget
            end try
        end if

        open theTarget using appPath
    end tell
    """
    import applescript
    applescript.asrun(ascript)


# print results({'~query': 'foobartest'}, 'sublime livingdocs-api')['run_args']
# print run(results({'~query': 'home'}, 'sublime livingdocs-api')['run_args'][0])
# mdfind 'livingdocs-api' | grep -v '/Library'
