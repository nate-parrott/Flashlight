import os

def run(type):
	from applescript import asrun, asquote
	ascript = '''
on to_hex(int)
	set the hex_list to {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"}
	set x to item ((int div 16) + 1) of the hex_list
	set y to item ((int mod 16) + 1) of the hex_list
	return (x & y) as string
end to_hex

on color_component_to_hex(c)
	return to_hex(round (c / 65535 * 255))
end color_component_to_hex

tell application "System Events"
    set activeApp to name of first application process whose frontmost is true
end tell
tell application activeApp
	set the_color to choose color
end tell
set color_type to "%s"
if color_type is "hex" then
	set the_string to ("#" & color_component_to_hex(item 1 of the_color) & color_component_to_hex(item 2 of the_color) & color_component_to_hex(item 3 of the_color)) --hex color
end if
if color_type is "UIColor" then
	set the_string to "[UIColor colorWithRed:" & ((item 1 of the_color) / 65536) & " green:" & ((item 2 of the_color) / 65536) & " blue:" & ((item 3 of the_color) / 65536) & " alpha:1]" --uicolor
end if
set the clipboard to the_string
display notification "Copied '" & the_string & "' to clipboard."
	'''%(type)
	asrun(ascript)

def results(parsed, original_query):
	type = 'UIColor' if 'copy_uicolor' in parsed else 'hex'
	return {
		"title": "Copy color as {0} (press enter)".format(type),
		"run_args": [type]
	}
