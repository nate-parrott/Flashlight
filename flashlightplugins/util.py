import os
import calendar
import time
import random
import jinja2

JINJA_ENVIRONMENT = jinja2.Environment(
    loader=jinja2.FileSystemLoader(os.path.dirname(__file__)),
    extensions=['jinja2.ext.autoescape'],
    autoescape=True)


def template(name, vars={}):
    template = JINJA_ENVIRONMENT.get_template(name)
    return template.render(vars)


def stable_daily_shuffle(items):
    timestamp = int(calendar.timegm(time.gmtime()))
    day = int(timestamp / (24 * 60 * 60))
    r = random.Random()
    r.seed(day)
    items = items[:]
    r.shuffle(items)
    return items

def language_suffixes(languages):
    for lang in languages:
        while True:
            yield "_" + lang if lang != 'en' else ''
            if '-' in lang:
                lang = lang[:lang.rfind('-')]
            else:
                break
    yield ''


def get_localized_key(dict, name, languages, default=None):
    for suffix in language_suffixes(languages):
        key = name + suffix
        if key in dict:
            return dict[key]
    return default
