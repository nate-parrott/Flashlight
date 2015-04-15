api_base = 'slack.com'


def results(fields, original_query):
    channel_n = fields['~channel']
    message_n = fields['~message']
    channel_split = channel_n.split()
    channel = channel_split[0]
    message = ''

    for x in xrange(1, len(channel_split)):
        message = message + channel_split[x] + ' '
    message = message + message_n

    import json

    settings = json.load(open('preferences.json'))

    token = settings.get('token')
    username = settings.get('username')

    title = 'Press Enter to Send Message'

    if not username or not token:
        channel = 'No Credentials'
        title = channel  # set the title to just "No Credentials"
        message = 'Please add your API Token that can be located at the bottom of <a href="https://api.slack.com/web">https://api.slack.com/web</a>'

    html = (
        open('slack.html').read().decode('utf-8') \
        .replace('<!--TO-->', channel) \
        .replace('<!--MESSAGE-->', message)
    )

    return {
        'title': title,
        'run_args': [channel, message],
        'html': html,
    }


def run(channel, message):
    if channel != 'No Credentials':
        import json
        import httplib, urllib

        # Load Settings
        settings = json.load(open('preferences.json'))
        token = settings.get('token')
        username = settings.get('username')
        display_notifications = settings.get('display_notifications')

        if channel == 'cache':
            if message == 'clear':
                import os
                os.remove('cache.json')

                if display_notifications:
                    post_notification('Cache cleared.')
                return True

        # Load Cache
        _cache_file = open('cache.json', 'w+')
        try:
            cache = json.loads(_cache_file.read())
        except ValueError:
            cache = {}

        if not cache:
            full_list = {
                'channels': {},
                'users': {},
            }

            conn = httplib.HTTPSConnection(api_base)
            conn.request('GET', '/api/channels.list?token=%s' % token)
            response = conn.getresponse()
            content = json.loads(response.read())
            for channel_data in content['channels']:
                full_list['channels'][channel_data['name']] = channel_data['id']
            conn.close()

            conn = httplib.HTTPSConnection(api_base)
            conn.request('GET', '/api/users.list?token=%s' % token)
            response = conn.getresponse()
            content = json.loads(response.read())
            for user_data in content['members']:
                full_list['users'][user_data['name']] = user_data['id']
            conn.close()

            _cache_file.seek(0)
            _cache_file.write(str(full_list))
            cache = full_list

        _cache_file.close()

        headers = {
            'Content-type': 'application/x-www-form-urlencoded',
            'Accept': 'text/plain'
        }
        conn = httplib.HTTPSConnection(api_base)

        needs_closed = False
        if channel.startswith('#'):
            pass
        elif channel.startswith('@'):
            needs_closed = True

        cleaned_channel = channel[1:]

        channel_id = ''
        error = False
        if needs_closed:
            user_id = cache['users'].get(cleaned_channel)

            if not user_id:
                error = True
            else:
                payload = {
                    'token': token,
                    'user': user_id,
                }
                conn.request('POST', '/api/im.open', urllib.urlencode(payload), headers)
                response = conn.getresponse()

                if response.status == 200:
                    content = response.read()

                    try:
                        content = json.loads(content)

                        if not content['ok']:
                            error = True
                        else:
                            if content.get('channel'):
                                channel_id = content['channel']['id']
                            else:
                                error = True
                    except ValueError:
                        post_notification('Unable to open Direct Message.')
                else:
                    error = True

            conn.close()

            if error:
                post_notification('Unable to open Direct Message.')
                return False
        else:
            channel_id = cache['channels'].get(cleaned_channel)
            if not channel_id:
                post_notification('Unable to post to %s.' % channel)
                return False

        payload = {
            'channel': channel_id,
            'text': unicode(message).encode('utf-8'),
            'token': token,
            'as_user': username,
        }

        # conn = httplib.HTTPSConnection(api_base)
        conn.request('POST', '/api/chat.postMessage', urllib.urlencode(payload), headers)
        response = conn.getresponse()

        content = response.read()
        content = json.loads(content)

        if response.status == 200:
            if display_notifications:
                if channel.startswith('#'):
                    post_notification('Message posted in %s' % channel)
                elif channel.startswith('@'):
                    post_notification('Message sent to %s' % channel)
        else:
            post_notification('Sending message failed.')


def post_notification(message, title='Flashlight'):
    import os, json, pipes
    # do string escaping:
    message = json.dumps(message)
    title = json.dumps(title)
    script = 'display notification {0} with title {1}'.format(message, title)

    os.system('osascript -e {0}'.format(pipes.quote(script)))
