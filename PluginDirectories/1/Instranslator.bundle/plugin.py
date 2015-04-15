lang_codes = {
    'spanish': 'es',
    'english': 'en',
    'arabic': 'ar',
    "french" : "fr",
    "german" : "de",
    'hindi' : "hi",
    'chinese' : "zh",
    'portuguese' : "pt",
    'brazilian' : "pt_br",
    "auto" : "auto"
}

def dark_mode():
    import Foundation
    return Foundation.NSUserDefaults.standardUserDefaults().persistentDomainForName_(Foundation.NSGlobalDomain).objectForKey_("AppleInterfaceStyle") == "Dark"

def results(parsed, original_query):
    if '~unknown_language' in parsed:
      from centered_text import centered_text
      return {
        "title": "Translate",
        "html": centered_text(u"Unsupported language: {0}".format(parsed['~unknown_language'])),
        "webview_transparent_background": True
      }
    if 'clipboard' in parsed:
      from copy_to_clipboard import clipboard_text
      text = clipboard_text()
    else:
      text = parsed['~text']
    from_lang = "auto"
    to_lang = "english"
    for key, val in parsed.iteritems():
        if key.startswith('from_language/'):
            from_lang = key.split('/')[1]
        elif key.startswith('to_language/'):
            to_lang = key.split('/')[1]
    from dark_mode import dark_mode
    color = "white" if dark_mode() else "black"
    html = open("translate.html").read().replace("----text----", text).replace("----fromlang----", lang_codes[from_lang]).replace("----tolang----", lang_codes[to_lang]).replace("----color----", color)


    if from_lang == 'auto':
        title = u"Translate \"{0}\" to {1}".format(text, to_lang)
    else:
        title = u"Translate \"{0}\" from {1} to {2}".format(text, from_lang, to_lang)
    return {
        "title": title,
        "html": html,
        "webview_transparent_background": True,
        "pass_result_of_output_function_as_first_run_arg": True,
        "run_args": []
    }

def run(text):
  from copy_to_clipboard import copy_to_clipboard
  if text != None:
    copy_to_clipboard(text.strip())
