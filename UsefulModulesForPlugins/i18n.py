from AppKit import NSLocale
import os

def language_suffixes():
  for lang in NSLocale.preferredLanguages():
    while True:
      yield "_" + lang if lang != 'en' else ''
      if '-' in lang:
        lang = lang[:lang.rfind('-')]
      else:
        break
  yield ''

def find_localized_path(path):
  path, ext = os.path.splitext(path)
  for suffix in language_suffixes():
    local_path = path+suffix+ext
    if os.path.exists(local_path):
      return local_path
  return path

def get(dict_obj, key, default=None):
  for suffix in language_suffixes():
    if key+suffix in dict_obj:
      return dict_obj[key+suffix]
  return None
