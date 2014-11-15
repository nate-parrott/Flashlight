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
            return "UIColor(white:%f)" % white
        else:
            return "[UIColor colorWithWhite:%ff]" % white
    else:
        if swift:
            return "UIColor(red:%f, green:%f, blue:%f)" % rgb
        else:
            return "[UIColor colorWithRed:%ff green:%ff blue:%ff]" % rgb


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
