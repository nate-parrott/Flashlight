from bs4 import BeautifulSoup
import urllib2


def appearance():
    import Foundation
    dark_mode = Foundation.NSUserDefaults.standardUserDefaults().persistentDomainForName_(Foundation.NSGlobalDomain).objectForKey_("AppleInterfaceStyle") == "Dark"
    return "dark" if dark_mode else "light"

def generate_html(query):
	url = "http://www.dfcd.net/projects/latex/latex.php?q=" + query
	webpage = urllib2.urlopen(url)
	soup = BeautifulSoup(webpage)
	table = soup.findAll('table')[-1]
	table = str(table).replace("./", "http://www.dfcd.net/projects/latex/")
    
	html = """
		<html>
			<head>
				<style>
					* {
						font-family: 'Helvetica Neue';
						font-size: 16px;
						font-weight: 200;
						text-align: center;
					}
                    table {
                        border: none;
                        background-color: #fff;
                        padding: 5px;
                        width: 100%;
                    }
					td {
                        border: none;
                        padding: 5px;
						-webkit-user-select: all;
					}
		
                    .dark {
                        color: #fff;
						padding: 10px 20px;
                    }
                    .light {
                        color: #000;
						padding: 10px 20px;
                    }
				</style>
			</head>
			<body>
    			<div class={{appearance}}>
                    <h4>Click a command, then &#8984; + C to copy</h4>
                    {{table}}
			   	</div>
           	</body>
	"""
	html = html.replace("{{appearance}}", appearance())
	html = html.replace("{{table}}", table)
	return html



def results(fields, original_query):
	query = fields['~message']
	return {
		"title" : "LaTeX Symbol Finder",
		"html" : generate_html(query),
		"webview_transparent_background" : True
	}

def run( output):
	import os
	os.system('printf "' + output + '" | pbcopy')

