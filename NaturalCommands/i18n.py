from AppKit import NSLocale
import os, json

def language_suffixes():
  for lang in NSLocale.preferredLanguages():
    while True:
      yield "_" + lang if lang != 'en' else ''
      if '-' in lang:
        lang = lang[:lang.rfind('-')]
      else:
        break
  yield ''

def find_localized_path(path, return_after_english=False):
  path, ext = os.path.splitext(path)
  for suffix in language_suffixes():
    if suffix == '' and return_after_english:
      return path
    local_path = path+suffix+ext
    if os.path.exists(local_path):
      return local_path
  return path

def get(dict_obj, key, default=None):
  for suffix in language_suffixes():
    if key+suffix in dict_obj:
      return dict_obj[key+suffix]
  return None

strings = None
def localstr(string):
  global strings
  if strings == None:
    path = find_localized_path('strings.json', True)
    if os.path.exists(path):
      strings = json.load(open(path))
    else:
      strings = {}
  return strings.get(string, string)
