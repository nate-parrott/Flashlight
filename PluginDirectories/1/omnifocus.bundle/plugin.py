 # -*- coding: utf-8 -*-
 #
 #icon designer:
 # interactivemania 
 #Creative Commons Attribution-No Derivative Works 3.0
 #http://www.defaulticon.com
 #
 #program author vicugna http://vicugna.github.io
 #
import urllib
import json
def results(fields, original_query): 
    param1 = urllib.quote_plus(fields.get('~omniFocusMemo', '').encode('UTF-8'))
    param2 = urllib.quote_plus(fields['~omniFocusNote'].encode('UTF-8'))
    omni_url = "omnifocus:///add?name="+param1+"&note="+param2
    return {
        "title": "SendOmniFocus name = '{0}' note = '{1}' ".format(param1,param2),
        "run_args":[omni_url]
    }
def run(url):
    import os
    os.system('open "{0}"'.format(url))
