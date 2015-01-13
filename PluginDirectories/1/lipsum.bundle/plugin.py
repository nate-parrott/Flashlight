import loremipsum
import re

def appearance():
    import Foundation
    dark_mode = Foundation.NSUserDefaults.standardUserDefaults().persistentDomainForName_(Foundation.NSGlobalDomain).objectForKey_("AppleInterfaceStyle") == "Dark"
    return "dark" if dark_mode else "light"


def generate(type, count, startWithLorem):
    sentences_count = 0
    words_count = 0
    if type == 'paragraphs':
        text = ''
        paragraphs = loremipsum.generate_paragraphs(count, startWithLorem)
        for paragraph in paragraphs:
            sentences_count += paragraph[0]
            words_count += paragraph[1]
            text += paragraph[2]+'\n\n'
    elif type == 'sentences':
        text = ''
        sentences = loremipsum.generate_sentences(count, startWithLorem)
        for sentence in sentences:
            sentences_count += sentence[0]
            words_count += sentence[1]
            text += sentence[2]+' '
    else:
        paragraphs = generate('paragraphs', 110, startWithLorem)[1]
        if count > 1000: count = 1000
        words_count += count
        text = ' '.join(paragraphs.split()[:count])


    stats = 'Generated'
    if sentences_count: stats += ' %s sentences' % (sentences_count)
    if words_count: stats += ' %s words' % (words_count)
    return [stats, text.strip()]


def build_html(stats, output):
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
                font-size: 12px;
            }

            .content {
                -webkit-user-select: all;
            }

            .dark{ color: rgb(224,224,224); }
        </style>
    </head>
    <body class="{{appearance}}">
        <h1>Lorem Ipsum <small>{{stats}}</small></h1>
        <div class="content">{{content}}</div>
    </body>
    </html>
    """

    html = html.replace('{{appearance}}', appearance())
    html = html.replace('{{stats}}', stats)
    return html.replace('{{content}}', output.replace('\n\n', '<br/><br/>'))


types = {
    'w' : 'words',
    'p' : 'paragraphs',
    'l' : 'sentences',
    's' : 'sentences'
}


def results(fields, original_query):
    if not fields.has_key('~query'): fields['~query'] = ''
    match = re.match('([0-9]*)\ ?([wpls])?', fields['~query'] or '')
    count = int(match.group(1) or 1)
    type = types[match.group(2) or 'p']

    stats, output = generate(type, count, False)
    return {
        'title': 'Lorem Ipsum %s %s' % (count, type),
        'run_args': [output],
        'html': build_html(stats, output),
        'webview_transparent_background': True,
    }


def run(output):
    import os
    os.system('printf "'+output+'" | pbcopy')
