from __future__ import print_function
# from Foundation import *
# from AppKit import *

import re, os, sys, getopt, logging

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

ch = logging.StreamHandler(sys.stdout)
ch.setLevel(logging.DEBUG)
# formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
# ch.setFormatter(formatter)
logger.addHandler(ch)

def echo(word):
    return "{0} {1}".format(word, word)

def get_checker():
    from Cocoa import NSSpellChecker
    checker = NSSpellChecker.sharedSpellChecker()
    return checker

def check_spelling(checker, string, start=0):
    from Cocoa import NSString
    _string = NSString.stringWithString_(string)
    _range, _count = checker.checkSpellingOfString_startingAt_language_wrap_inSpellDocumentWithTag_wordCount_(_string, start, None, False, 0, None)
    logger.debug('Check spelling: %s range: %s count: %d' % (string.encode('utf-8'), _range, _count))
    if _range.length == 0:
        return True, _count, None, None
    else:
        word = string[_range.location:_range.location+_range.length]
        logger.info('Misspelled word: ' + word.encode('utf-8'))
        return False, _count, _range, word

def guesses(checker, string, _range):
    from Cocoa import NSString, NSRange
    _string = NSString.stringWithString_(string)
    _words = checker.guessesForWordRange_inString_language_inSpellDocumentWithTag_(_range, _string, None, 0)
    n = len(_words)
    words = u', '.join(_words)
    logger.info('Guesses: ' + words)
    return n, words

def main(argv=None):
    if argv == None:
        argv = sys.argv

    if len(argv) < 1:
        print("Usage:", argv[0], " <term>")
        return 

    term = argv[1]
    print("Check:", term)
    ok, _count, _range, word = check_spelling(get_checker(), term)
    guesses(get_checker(), word, _range)
    return 0

if __name__ == '__main__':
    sys.exit(main())