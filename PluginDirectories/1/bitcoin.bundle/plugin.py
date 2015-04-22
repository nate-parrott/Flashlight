# -*- coding: utf-8 -*-
#!/usr/bin/python

import json
import AppKit
import codecs

api_url = 'https://api.bitcoinaverage.com/ticker/'

currencys = {
  'AUD':u'$',
  'BRL':u'R$',
  'CAD':u'$',
  'CHF':u'CHF',
  'CNY':u'¥',
  'EUR':u'€',
  'GBP':u'£',
  'IDR':u'Rp',
  'ILS':u'₪',
  'MXN':u'$',
  'NOK':u'kr',
  'NZD':u'$',
  'PLN':u'zł',
  'RON':u'lei',
  'RUB':u'руб',
  'SEK':u'kr',
  'SGD':u'$',
  'USD':u'$',
  'ZAR':u'R'
}

default_code = 'USD'

def select_currency(code=False):
    if not code:
        code = AppKit.NSLocale.currentLocale().objectForKey_(AppKit.NSLocaleCurrencyCode)
    symbol = currencys.get(code)
    if symbol:
        url = api_url + code
    else: #No key found, either from auto or manual code
        symbol = currencys[default_code]
        url = api_url + default_code
    return url, symbol


def results(parsed, original_query):
    count = str(1)
    if'~n' in parsed.keys():
        count = parsed['~n']

    settings = json.load(open('preferences.json'))
    url, symbol = select_currency(settings['currency_code'])

    # We need to open temp.html as unicode to allow us to insert unicode symbols
    html = (codecs.open('temp.html', 'r', 'utf-8').read()
        .replace('<!--url-->', url)
        .replace('<!--count-->', count)
        .replace('<!--symbol-->', symbol))
    return {
        'title': ("Bitcoin price" if count=="1" else "Price of {0} bitcoins".format(count)),
        'html': html
    }
