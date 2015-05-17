def results(fields, original_query):
    import json
    preferences = json.load(open('preferences.json'))

    fields['hipchaturl'] = preferences['hipchaturl']
    fields['token'] = preferences['token']

    user = fields.get('~user', '')
    message = fields.get('~message', '')

    user, displayname = get_user_information(user, preferences['aliaslist'])
    fields['user'] = user
    fields['displayname'] = displayname
    htmloutput = open('view.html').read().replace("<!--RECIPIENT-->", user).replace("<!--BODY-->", message)

    return {
      "title": "Message to '{0}': {1}".format(user, message),
      "run_args": [fields],
      "html": htmloutput
    }


def get_user_information(user, aliaslist):

    for val in aliaslist or ():
        if 'alias' in val and val['alias'] == user:
            return (val['hipchatalias'], user)

    return (user, user)


def run(parsed):
    import os
    import urllib2

    data = parsed.get('~message', ['']).encode('utf8')
    user = parsed.get('user', [''])
    displayname = parsed.get('displayname', [''])
    hipchaturl = parsed.get('hipchaturl', [''])
    token = 'Bearer %s' % parsed.get('token', [''])

    url = '%s/v2/user/%s/message' % (hipchaturl, user)
    req = urllib2.Request(url, data, {'Content-Type': 'text/plain', 'Authorization': token})

    title = displayname
    message = data
    try:
      urllib2.urlopen(req)
    except urllib2.URLError, err:
        if err.code == 404:
            title = 'URL error %s' % str(err.code)
            message = 'Check your configured Hipchat Server URL.'
        else:
            title = 'URL error'
            message = 'URL error' % err.code
    except urllib2.HTTPError, err:
        if err.code == 404:
            title = 'User (%s) not found' % user
            message = 'Message could not be delivered.'
        elif err.code == 401:
            title = 'Unauthorized'
            message = 'Check your configured Hipchat token.'
        else:
            title = 'Network error'
            message = 'HTTP error' % err.code

    os.system('echo ' + data + " | pbcopy && osascript -e 'display notification \"" + message + "\" with title \"" + title + "\"'")
