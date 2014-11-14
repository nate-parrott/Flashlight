import re

def piglatin(english):
    def preserve_case(fn):
        def wrapped(text):
            all_upper = text == text.upper()
            first_upper = text[0] == text[0].upper() and text[1:] == text[1:].lower()
            result = fn(text.lower())
            if all_upper:
                return result.upper()
            elif first_upper:
                return result[0].upper() + result[1:]
            else:
                return result
        return wrapped
    
    @preserve_case
    def translate_word(word):
        initial_consonants = u""
        for c in word:
            if c in 'aeiou':
                break
            else:
                initial_consonants += c
        return word[len(initial_consonants):] + initial_consonants + "ay"
    
    return re.sub(r"[a-zA-Z]+", lambda match: translate_word(match.group()), english);

assert piglatin("hello world") == "ellohay orldway"
assert piglatin("i am happy. day") == "iay amay appyhay. ayday"


def results(parsed, original_query):
    html = """
    <h2 style='font-weight: normal; font-family: "HelveticaNeue-Light", "Helvetica Neue Light", "Helvetica Neue", Helvetica, Arial; line-height: 1.2'>
    {0}
    </h2>""".format(piglatin(parsed['~text']))
    return {
        "title": "'{0}' in Pig Latin".format(parsed['~text']),
        "html": html
    }
