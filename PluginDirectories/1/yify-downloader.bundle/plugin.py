def appearance():
    import Foundation
    dark_mode = Foundation.NSUserDefaults.standardUserDefaults().persistentDomainForName_(Foundation.NSGlobalDomain).objectForKey_("AppleInterfaceStyle") == "Dark"
    return "dark" if dark_mode else "light"

import urllib2, urllib, time, json, logging, webbrowser
def results(fields, original_query):
    time.sleep(0.2)    
    message = fields['~message']    
    req = urllib2.Request('https://yts.to/api/v2/list_movies.json?quality=1080p&query_term={0}'.format(urllib.quote_plus(message)))
    response = urllib2.urlopen(req)
    the_page = response.read()
    result = json.loads(the_page)    
    tmpl = open('template.html')
    html = tmpl.read()
    html = html.replace('{{appearance}}', appearance())
    
    magnet = ""
    
    if len(result['data']['movies']) > 0 :
        magnet = get_magnet(result['data']['movies'][0]['torrents'][0]['hash'], result['data']['movies'][0]['slug'])        
    
    html = html.replace('{{JSON}}', the_page)            
    
    return {
        "title": "Download torrent for '{0}'".format(message),
        "run_args": [magnet],  # ignore for now,
        "html": html,
        'webview_transparent_background': True
    }
    
trackers = [
    'udp://open.demonii.com:1337',
    'udp://tracker.istole.it:80',
    'http://tracker.yify-torrents.com/announce',
    'udp://tracker.publicbt.com:80',
    'udp://tracker.openbittorrent.com:80',
    'udp://tracker.coppersurfer.tk:6969',
    'udp://exodus.desync.com:6969',
    'http://exodus.desync.com:6969/announce'
]

def get_magnet(hash, title):
    template = 'magnet:?xt=urn:btih:{0}&dn={1}&tr='.format(hash, title) + '&tr='.join(trackers)
    return template


def run(magnet):
    import os
    os.system('open "{0}"'.format(magnet))