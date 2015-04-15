from model import Plugin
from util import template, stable_daily_shuffle, get_localized_key
import json
import urllib
from search import search_plugins
import random

def arrays_overlap(a1, a2):
  return sum([1 for a in a1 if a in a2]) > 0

def locales_overlap(l1, l2):
  normalize_locale = lambda locale: locale.split('-')[0]
  return arrays_overlap(map(normalize_locale, l1), map(normalize_locale, l2))

def group_plugins(plugin_dicts, languages, languages_were_specified):
  if languages_were_specified:
    plugins_for_other_locales = [p for p in plugin_dicts if ('preferred_locales' in p and not locales_overlap(p['preferred_locales'], languages))]
    plugins_for_other_locales_names = set([p['name'] for p in plugins_for_other_locales])
    native_plugins = [p for p in plugin_dicts if p['name'] not in plugins_for_other_locales_names]
    groups = [
      {"plugins": native_plugins},
      {"plugins": plugins_for_other_locales, "header": "Plugins for other regions", "class": "other_locales"}
    ]
  else:
    groups = [{"plugins": plugin_dicts}]
  return [g for g in groups if len(g['plugins'])]

def directory_html(category=None, search=None, languages=None, browse=False,
                   name=None, gae=None, deep_links=False):
    
    if gae == None:
      gae = not browse
    
    new = category == 'New'
    if new: category = None
    
    languages_specified = languages != None
    if not languages_specified:
      languages = ['en']
    if category:
        plugins = list(Plugin.query(Plugin.categories == category,
                                    Plugin.approved == True))
        plugins = stable_daily_shuffle(plugins)
    elif search:
        plugins = search_plugins(search)
    elif name:
        plugin = Plugin.by_name(name)
        plugins = [plugin] if plugin else []
    elif new:
        plugins = Plugin.query(Plugin.approved == True).order(-Plugin.added).fetch(limit=10)
    else:
        plugins = []
    count = len(plugins)
    plugin_dicts = []
    for p in plugins:
        plugin = info_dict_for_plugin(p, languages)
        plugin_dicts.append(plugin)
    groups = group_plugins(plugin_dicts, languages, languages_specified)
    return template("directory.html",
                    {
                      "groups": groups,
                      "browse": browse,
                      "count": count,
                      "search": search,
											"deep_links": deep_links,
                      "new": new,
                      "gae": gae})


def info_dict_for_plugin(p, languages=['en']):
    plugin = json.loads(p.info_json)
    plugin['displayName'] = get_localized_key(plugin, "displayName", languages,
                                              "")
    plugin['description'] = get_localized_key(plugin, "description", languages,
                                              "")
    plugin['examples'] = get_localized_key(plugin, "examples", languages, [])
    plugin['model'] = p
    for (scheme, key) in [('install', 'install_url'), ('update', 'update_url')]:
      plugin[key] = scheme + '://_?' + \
                              urllib.urlencode([("zip_url", p.zip_url),
                                                ("name", p.name.encode('utf8'))])
    return plugin
