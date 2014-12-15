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

def results(parsed, original_query):
    if '~unknown_language' in parsed:
      from centered_text import centered_text
      return {
        "title": "Translate",
        "html": centered_text(u"Unsupported language: {0}".format(parsed['~unknown_language'])),
        "webview_transparent_background": True
      }
    text = parsed['~text']
    from_lang = "auto"
    to_lang = "english"
    for key, val in parsed.iteritems():
        if key.startswith('from_language/'):
            from_lang = key.split('/')[1]
        elif key.startswith('to_language/'):
            to_lang = key.split('/')[1]
    html = open("translate.html").read().replace("----text----", text).replace("----fromlang----", lang_codes[from_lang]).replace("----tolang----", lang_codes[to_lang])
    if from_lang == 'auto':
        title = "Translate \"{0}\" to {1}".format(text, to_lang)
    else:
        title = "Translate \"{0}\" from {1} to {2}".format(text, from_lang, to_lang)
    return {
        "title": title,
        "html": html
    }
