import json, subprocess


def appearance():
    import Foundation
    dark_mode = Foundation.NSUserDefaults.standardUserDefaults().persistentDomainForName_(Foundation.NSGlobalDomain).objectForKey_("AppleInterfaceStyle") == "Dark"
    return "dark" if dark_mode else "light"


def build_html(file, directories):
    html = """
    <html>
    <head>
        <style>
            body{
                padding: 10px 12px;
                font: 15px/1.4 'Helvetica Neue';
                font-weight: 300;
                -webkit-user-select: none;
            }

            h1 {
                font-size: 20px;
                font-weight: 300;
            }

            h1 small {
                margin-left: 5px;
                color: rgb(119,119,119);
            }

            label, small {
                font-size: 12px;
                overflow: hidden;
                white-space: nowrap;
            }

            label {
                display: block;
                font-size: 11px;
                -webkit-user-select: all;
            }

            .highlight {
            }

            ul li {
                border-bototm
            }

            .dark {
                color: rgb(224,224,224);
            }
        </style>
    </head>
    <body class="{{appearance}}">
        <div class="message"></div>
        {{content}}
    </body>
    </html>
    """.replace("{{appearance}}", appearance())

    content = ''
    if file:
        content += """
        <div class="highlight">
            <span class="icon"></span>
            <div class="name">%s</div>
            <div class="items">9 items</div>
        </div>
        """ % (file)

    content += '<ul>'
    for directory in directories:
        content += """
        <li>
            <span class="icon"></span>
            <div class="name">%s</div>
            <div class="items">9 items</div>
        </li>
        """ % (directory)
    content += '</ul>'

    return html.replace("{{content}}", content)


def get_alias(name, aliases):
    for val in aliases or ():
        if val.has_key('name') and val['name'] == name:
            return val['path']


def results(params, original_query):
    query = params['~query'] if params.has_key('~query') else ''
    config = json.load(open('preferences.json'))
    title = "Open with Sublime Text"
    files = subprocess.check_output("mdfind -name '{{query}}' | grep -v '/Library'".replace('{{query}}', query), shell=True).split('\n')[:20]

    file = get_alias(query, config['aliases'])
    file_to_open = file or files[0]

    return {
        "title": query,
        'html': build_html(file, files),
        "run_args": [file_to_open],
        'webview_transparent_background': True
    }


def run(file):
    if not file: return open_finder_item()
    open_file(file)


def open_file(path):
    import subprocess
    command = 'open -a "Sublime Text" %s' % (path)
    subprocess.call([command], shell=True)


def open_finder_item():

    ascript = """
    set finderSelection to ""
    set theTarget to ""
    set appPath to path to application "Sublime Text"
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


# print results({'~query': 'home'}, 'sublime livingdocs-api')
# print run(results({'~query': 'home'}, 'sublime livingdocs-api')['run_args'][0])
# mdfind 'livingdocs-api' | grep -v '/Library'
