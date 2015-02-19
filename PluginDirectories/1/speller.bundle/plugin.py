import re, os, sys, getopt, logging
import subprocess

def get_checker():
    from Cocoa import NSSpellChecker
    checker = NSSpellChecker.sharedSpellChecker()
    return checker

def check_spelling(checker, string, start=0):
    from Cocoa import NSString
    _string = NSString.stringWithString_(string)
    _range, _count = checker.checkSpellingOfString_startingAt_language_wrap_inSpellDocumentWithTag_wordCount_(_string, start, None, False, 0, None)
    # logger.debug('Check spelling: %s range: %s count: %d' % (string.encode('utf-8'), _range, _count))
    if _range.length == 0:
        return True, _count, None, None
    else:
        word = string[_range.location:_range.location+_range.length]
        # logger.info('Misspelled word: ' + word.encode('utf-8'))
        return False, _count, _range, word

def guesses(checker, string, _range):
    from Cocoa import NSString, NSRange
    _string = NSString.stringWithString_(string)
    _words = checker.guessesForWordRange_inString_language_inSpellDocumentWithTag_(_range, _string, None, 0)
    n = len(_words)
    words = u', '.join(_words)
    # logger.info('Guesses: ' + words)
    return n, words

def to_html(ok, word, n, suggestions):
    page1 = open('template_base.html')
    html_template_base = page1.read()

    html = html_template_base.replace("#TERM#", word, 1)

    if not ok:
        page2 = open('template_listitem.html')
        html_template_listitem = page2.read()
        list_html = ""
        for guess in suggestions:
            list_html += html_template_listitem.replace("#GUESS#", guess.strip(), 1)
        html = html.replace("<!-- #LIST# -->", list_html, 1)

    return html

def results(fields, original_query):
    if '~word' not in fields:
        return

    term = fields['~word']
    checker = get_checker()

    # word = echo(term)
    # ok = False
    ok, _count, _range, word = check_spelling(checker, term)
    
    n = 0
    words = ""
    if not ok:
        n, words = guesses(checker, word, _range)

    suggestions = words.split(',')

    return {
        "title": "'{0}'".format(term),
        "run_args": [suggestions[0]] if len(suggestions)>0 else [term],
        "webview_transparent_background": True,
        "html": to_html(ok, term, n, suggestions)
    }

def set_clipboard_data(data):
    p = subprocess.Popen(['pbcopy'], stdin=subprocess.PIPE)
    p.stdin.write(data)
    p.stdin.close()
    retcode = p.wait()

def run(word):
    # import os, pipes
    # os.system('say "{0}"'.format(pipes.quote(word.encode('utf8'))))
    set_clipboard_data(word)
