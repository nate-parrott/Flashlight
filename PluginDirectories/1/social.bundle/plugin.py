import sys
from AddressBook import *

def personWithName(name, people):
    for (idx, person) in enumerate(people):
        firstName = person.valueForProperty_(kABFirstNameProperty)
        lastName = person.valueForProperty_(kABLastNameProperty)

        firstMatch = (name.find(firstName) != -1)
        lastMatch = (name.find(lastName) != -1)

        if firstMatch and lastMatch:
            return person


def results(parsed, original_query):
    addressBook = ABAddressBook.sharedAddressBook()

    # html = """
    # <h2 style='font-weight: normal; font-family: "HelveticaNeue-Light", "Helvetica Neue Light", "Helvetica Neue", Helvetica, Arial; line-height: 1.2'>
    # {0}
    # </h2>""".format(piglatin(parsed['~text']))
    # return {
    #     "title": "'{0}' in Pig Latin".format(parsed['~text']),
    #     "html": html
    # }
