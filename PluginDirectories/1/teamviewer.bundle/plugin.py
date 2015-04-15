def split_by_n( string, n ):
    arr = [string[i:i+n] for i in range(0, len(string), n)]
    return ' '.join(arr)


def build_html(title, description, teamviewer_id, teamviewer_password):
    html = """
    <html>
    <head>
        <style>
            html {
                font: 15px/1.5 'Helvetica Neue';
                font-weight: 300;
                width: 100%;
                height: 100%;
                margin: 0px;
                -webkit-user-select: none;
            }

            body {
               display: flex;
               background: transparent url('map.jpg') center center;
               background-size: cover;
            }

            a, a:link, a:focus, a:visited, b {
                color: rgb(0, 146, 232);
                font-weight: 500;
                text-decoration: none;
            }

            h1 {
                margin-top: 80px;
                font-weight: 400;
                font-size: 20px;
                color: rgb(0, 123, 210);
                text-align: center;
            }

            form {
                display: block;
                margin: auto;
                padding:  6px 15px;
                width: 60vw;
                background: #F9F9F9;
                color: rgb(0, 146, 232);
                border: 1px solid rgb(208, 217, 224);
                border-radius: 8px;
                text-align: left;
            }

            .description {
                text-align: center;
            }

            .description:empty, .partner:empty, .password:empty {
               display: none;
            }

            .partner, .password {
                padding-right: 1em;
                text-overflow: ellipsis;
                white-space: nowrap;
                overflow: hidden;
            }

            .password {
                border-top: 1px solid #eee;
                padding-top: 1em;
            }

            .password:before, .partner:before {
               content: attr(title);
               margin-right: 10px;
            }

        </style>
    </head>
    <body>
        <h1 class="title">{{title}}</h1>
        <form>
            <p class="description">{{description}}</p>
            <p class="partner" title="Partner ID:\t">{{teamviewer_id}}</p>
            <p class="password" title="Password:\t">{{teamviewer_password}}</p>
        </form>
    </body>
    </html>
    """

    html = html.replace("{{title}}", title or '')
    html = html.replace("{{description}}", description or '')
    html = html.replace("{{teamviewer_id}}", split_by_n(teamviewer_id, 3))
    return html.replace("{{teamviewer_password}}", teamviewer_password or '')


APP_PATH = '/Applications/TeamViewer.app'
import os
def results(params, original_query):
    title = 'Control Remote Computer'
    description = ''
    teamviewer_id = params['~id'].replace(' ', '') if params.has_key('~id') else None
    teamviewer_password = params['~password'].replace(' ', '') if params.has_key('~password') else None

    if not os.path.isdir(APP_PATH):
        title = 'TeamViewer not installed'
        description = 'Please download TeamViewer at <a href="http://teamviewer.com">http://teamviewer.com</a><br/>and move it to<br/><b>/Applications/Teamviewer.app</b>'
        teamviewer_id = ''
        teamviewer_password = ''

    return {
        'title': 'Press return to connect to the teamviewer session',
        'run_args': [teamviewer_id, teamviewer_password],
        'html': build_html(title, description, teamviewer_id, teamviewer_password),
        'webview_links_open_in_browser': True
    }


def run(teamviewer_id, teamviewer_password):
    import subprocess
    command = 'osascript -e \'display notification "Opening Teamviewer Session %s" with title "Flashlight"\'' % (teamviewer_id)
    command += ' && %s/Contents/MacOS/TeamViewer' % (APP_PATH)
    if teamviewer_id: command += ' -i '+teamviewer_id
    if teamviewer_password: command += ' -p '+teamviewer_password
    subprocess.call([command], shell=True)


# test
# print results({'~id': '330 161 409'}, 'teamviewer 123')
# args = results({'~id': '330 161 409', '~password': '123 123'}, 'teamviewer 330 161 409, 123')['run_args']
# print run(args[0], args[1])
