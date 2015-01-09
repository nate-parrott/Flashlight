# -*- coding: utf-8 -*-

def results(fields, original_query):
    import cowsay
    message = fields['~message']
    html = "<pre>" + cowsay.cowsay(message) + "</pre>"
    return {
        "title": "Cowsay '{0}'".format(message),
        "html": html
    }