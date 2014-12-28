#!/usr/bin/env python

import urllib2
import xml.sax
from optparse import OptionParser

def get_lipsum(howmany, what, start_with_lipsum):
	
	class XmlHandler(xml.sax.handler.ContentHandler):
		
		def __init__(self):
			self.lipsum = ''
			self.generated = ''
		
		def startElement(self, name, attrs):
			self.current_tag = name
		
		def endElement(self, name):
			self.current_tag = None
		
		def characters(self, content):
			if self.current_tag == 'lipsum':
				self.lipsum += content
			elif self.current_tag == 'generated':
				self.generated += content
	
	query_str  = "amount=" + str(howmany)
	query_str += "&what=" + what
	query_str += "&start=" + start_with_lipsum
	
	f = urllib2.urlopen("http://www.lipsum.com/feed/xml", query_str)
	
	handler = XmlHandler()
	parser = xml.sax.make_parser()
	parser.setContentHandler(handler)
	parser.parse(f)
	
	f.close()
	
	return handler.lipsum, handler.generated

get_lipsum.__doc__ = """Get lorem ipsum text from lipsum.com. Parameters:
howmany: how many items to get
what: the type of the items [paras/words/bytes/lists]
start_with_lipsum: whether or not you want the returned text to start with Lorem ipsum [yes/no]
Returns a tuple with the generated text on the 0 index and generation statistics on index 1"""

if __name__ == "__main__":
	from optparse import OptionParser
	optionParser = OptionParser()
	optionParser.add_option(
		"-n","--howmany",
		type="int",
		dest="howmany",
		metavar="X",
		help="how many items to get"
	)
	whatChoices = ('paras','words','bytes','lists')
	optionParser.add_option(
		"-w","--what",
		choices=whatChoices,
		dest="what",
		metavar="TYPE",
		help="the type of items to get: " + ', '.join(whatChoices)
	)
	optionParser.add_option(
		"-l","--start-with-Lorem",
		action="store_true",
		dest="lipsum",
		help='Start the text with "Lorem ipsum"'
	)
	optionParser.set_defaults(
		lipsum=False,
		howmany=5,
		what="paras"
	)
	(opts,args) = optionParser.parse_args()
	if 3 == len(args): # for backward compatibility with arg-only version
		opts.howmany = args[0]
		opts.what = args[1]
		opts.lipsum = 'yes' == args[2]
	lipsum = get_lipsum(
		opts.howmany, opts.what,
		'yes' if opts.lipsum else 'no'
	)
	print lipsum[0] + "\n\n" + lipsum[1]
