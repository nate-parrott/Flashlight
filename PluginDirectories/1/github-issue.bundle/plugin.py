import copy, re, json


def replace_tokens(html, content):
    if content.get('organisation'): html = html.replace("{{organisation}}", content.get('organisation'))
    html = html.replace("{{repository}}", content.get('repository') or '?')
    html = html.replace("{{title}}", content.get('title') or '')
    if isinstance(content.get('labels'), basestring): html = html.replace("{{labels}}", content.get('labels'))
    return html.replace("{{content}}", content.get('content') or '')


def build_html(template, content, config):
    html = open(template+'.html').read().decode('utf-8')
    html = html.replace("{{url}}", build_url(content))

    content = copy.copy(content)
    content['labels'] = build_label_html(content.get('labels'), config)
    html = replace_tokens(html, content)
    html = html.replace('{{user_id}}', config.get('user_id') or '')
    html = html.replace('{{user_name}}', config.get('user_name') or '')
    html = html.replace('{{organisation}}', config.get('user_name') or '?')
    return html


def get_alias(name, aliases):
    for val in aliases:
        if val['src'] == name: return val['dst']


def get_color(name, colors):
    for color in colors:
        if color['name'] == name:
            return {
                "color": color.get('color') or "rgb(51,51,51)",
                "background": color.get('background') or "white",
                "border": color.get('border') or "transparent"
            }


def build_label_html(labels, config):
    html = ''
    if labels:
        if not config.has_key('colors'): config['colors'] = []
        for label in labels:
            color = get_color(label, config['colors'])
            if not color:
                color = {"color": "rgb(51,51,51)", "background": "white", "border": "rgb(210,210,210)"}
            style = 'color: %s; background: %s; border-color: %s;' % (color.get('color'), color.get('background'), color.get('border'))
            html += """<li class="label" style="%s"><span class="label-name">%s</span></li>""" % (style, label)
    return html


def build_url(content):
    url = replace_tokens('http://github.com/{{organisation}}/{{repository}}/issues/new?title={{title}}&body={{content}}', content)
    if content.has_key('labels'):
        for label in content.get('labels'):
            url += '&labels[]='+label
    return url


def parse_query(query, config):
    organisation = config.get('organisation') or ''
    repository = None
    title = None
    content = None
    labels = []

    match = re.match('([a-zA-Z0-9\-\._\/]*)\ ?(.*)?', query)
    if match:
        if not config.has_key('aliases'): config['aliases'] = []
        alias = get_alias(match.group(1), config['aliases']) or match.group(1)
        organisation_and_repository = alias.split('/', 1)
        if len(organisation_and_repository)>1:
            organisation, repository = organisation_and_repository
        elif len(organisation_and_repository)==1:
            repository = organisation_and_repository[0]

        title_and_content = match.group(2)
        contains_label = re.match('.*\ ?labels?=([a-zA-Z,;\.]*).*', title_and_content)
        if contains_label:
            labels = filter(None, re.split(',|;', contains_label.group(1)))
            title_and_content = re.compile("(.*)\ ?labels?=[a-zA-Z,;\.]*\ ?(.*)").split(title_and_content)
            title_and_content = ' '.join(title_and_content)

        title_and_content = title_and_content.split(',', 1)
        if len(title_and_content)==2:
            title, content = title_and_content
            content = content.replace('  ', '\n').strip()
        elif len(title_and_content)==1:
            title = title_and_content[0]

    return {
        "organisation": organisation,
        "repository": repository,
        "title": title,
        "content": content,
        "labels": labels
    }


# Query
# ghi upfrontIO/livingdocs-engine Issue title
def results(params, original_query):
    query = params['~query'] if params.has_key('~query') else ''
    title = 'Create a new issue'
    config = json.load(open('preferences.json'))
    content = parse_query(query, config)

    return {
        'title': title,
        'run_args': [content, config],
        'html': build_html('create', content, config),
        'webview_links_open_in_browser': True
    }


def run(content, config):
    import subprocess
    url = build_url(content)
    subprocess.call(["""open '%s' """ %(url)], shell=True)


# test
# print results({'~query': 'engine labels=foo'}, 'ghi upfrontIO/livingdocs-editor')
# run(*results({'~query': 'alias engine=upfrontIO/livingdocs-engine'}, '')['run_args'])
