import re

_NUMERALS = '0123456789abcdefABCDEF'
_HEXDEC = {v: int(v, 16) for v in (x+y for x in _NUMERALS for y in _NUMERALS)}

def rgb(triplet):
    return _HEXDEC[triplet[0:2]], _HEXDEC[triplet[2:4]], _HEXDEC[triplet[4:6]]

def colorString(rgb, swift = False):
    isGray = (rgb[0] == rgb[1] and rgb[1] == rgb[2])
    if isGray:
        white = rgb[0]/255.0
        if swift:
            return "UIColor(white: {0:.3f})".format(white)
        else:
            return "[UIColor colorWithWhite: {0:.3f}f]".format(white)
    else:
        if swift:
            return "UIColor(red: {0:.3f}, green: {1:.3f}, blue: {2:.3f})".format(rgb[0], rgb[1], rgb[2])
        else:
            return "[UIColor colorWithRed: {0:.3f}f green: {1:.3f}f blue: {2:.3f}f]".format(rgb[0], rgb[1], rgb[2])


def results(parsed, original_query):
    useSwift = "swift" in original_query
    hexValue = parsed["color"]
    values = rgb(hexValue)
    string = colorString(values, useSwift)

    html = """
	<h2 style='font-weight: normal; font-family: "HelveticaNeue-Light", "Helvetica Neue Light", "Helvetica Neue", Helvetica, Arial; line-height: 1.2'>
	{0}
	</h2>""".format(string)

    return {"title": "'UIColor from {0}'".format(hexValue), "html": html}
