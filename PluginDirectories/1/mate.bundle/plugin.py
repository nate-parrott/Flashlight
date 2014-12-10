import os

def results(parsed, original_query):
	return {
        "title": "Open with Textmate",
        "run_args": [original_query]
    }

def run(query):
	from applescript import asrun, asquote
	from pipes import quote

	ascript = '''
	set finderSelection to ""
	set theTarget to ""
	set appPath to path to application "Textmate"
	set defaultTarget to (path to home folder as alias)

	tell application "Finder"
		set finderSelection to (get selection)
        if length of finderSelection is greater than 0 then
            set theTarget to finderSelection
        else
            try
                set theTarget to (folder of the front window as alias)
            on error
                set theTarget to defaultTarget
            end try
        end if

        open theTarget using appPath
    end tell

	'''

	asrun(ascript)
