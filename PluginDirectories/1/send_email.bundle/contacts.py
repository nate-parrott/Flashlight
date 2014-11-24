import objc
import AddressBook as ab
 
import pprint as pp
 
def find_contact(query, address_book, wants_field=None):
   normalized_query = normalize(query)
   scored_matches = []
   field_weights = {"first": 2, "last": 2, "organization": 1.5}
   for item in address_book:
       s = 0
       if wants_field and wants_field not in item: continue
       for field_name, field in item.iteritems():
           weight = field_weights.get(field_name, 0)
           if weight == 0: continue
           s += weight * score(query.lower(), field.lower()) * 0.1 # perfect word match
           s += weight * score(normalized_query, normalize(field))
       if 'socialprofile' in item:
           s *= 0.9 # penalize social-network-synced accounts
       if s:
           scored_matches.append((item, s))
   scored_matches.sort(key=lambda (_,score): score)
   # pp.pprint(scored_matches)
   return scored_matches[-1][0] if len(scored_matches) else None
 
 
import unicodedata
def strip_accents(s):
    return ''.join(c for c in unicodedata.normalize('NFD', s)
               if unicodedata.category(c) != 'Mn')
 
def pythonize(objc_obj):
    if isinstance(objc_obj, objc.pyobjc_unicode):
        return unicode(objc_obj)
    elif isinstance(objc_obj, ab.NSDate):
        return objc_obj.description()
    elif isinstance(objc_obj, ab.NSCFDictionary):
        # implicitly assuming keys are strings...
        return {k.lower(): pythonize(objc_obj[k])
                for k in objc_obj.keys()}
    elif isinstance(objc_obj, ab.ABMultiValueCoreDataWrapper):
        return [pythonize(objc_obj.valueAtIndex_(index))
                for index in range(0, objc_obj.count())]
 
 
_default_skip_properties = frozenset(("com.apple.ABPersonMeProperty",
                                      "com.apple.ABImageData"))
def ab_person_to_dict(person, skip=None):
    skip = _default_skip_properties if skip is None else frozenset(skip)
    props = person.allProperties()
    return {prop.lower(): pythonize(person.valueForProperty_(prop))
            for prop in props if prop not in skip}
 
def address_book_to_list():
    """
    Read the current user's AddressBook database, converting each person
    in the address book into a Dictionary of values. Some values (addresses,
    phone numbers, email, etc) can have multiple values, in which case a
    list of all of those values is stored. The result of this method is
    a List of Dictionaries, with each person represented by a single record
    in the list.
 
    Function adapted from: https://gist.github.com/pklaus/1029870
    """
    address_book = ab.ABAddressBook.sharedAddressBook()
    people = address_book.people()
    return [ab_person_to_dict(person) for person in people]

def score(query, field):
    if field == query:
        return 1
    s = 0
    for word in query.split(" "):
        if word == field:
            s += 0.1
        elif word in field:
            s += 0.01
    return s

def normalize(s):
    s = s.lower()
    if type(s) == unicode:
        return strip_accents(s)
    else:
        return s
