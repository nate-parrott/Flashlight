#!/usr/bin/python

import os
import commanding
from parse_example import parse_example_to_phrase
import sys
import json
import imp
from shared import plugin_dir, WorkingDirAs

example_phrases = []
plugins_to_always_invoke = set()
regexes = {}

# add baseline nonsense parses:
example_phrases.append(commanding.Phrase("", ["ihrfeiiehrgogiheog"]))
example_phrases.append(commanding.Phrase("", ["ihrfeio iehrgogih eog"]))
example_phrases.append(commanding.Phrase("", ["eyfght oehrgueig erobf", ["ehheiog","hegoegn"]]))
example_phrases.append(commanding.Phrase("", ["wurt turt gurt", ["~burt", "nurt"]]))
example_phrases.append(commanding.Phrase("", [["~uirguieg", "hgeough egoiheroi"]]))
example_phrases.append(commanding.Phrase("", [["~uirguieg", "hgeoughegoiheroi"]]))

for plugin in os.listdir(plugin_dir):
    if os.path.isdir(os.path.join(plugin_dir, plugin)):
        plugin_name, extension = os.path.splitext(plugin)
        if extension == '.bundle':
            examples_file = os.path.join(plugin_dir, plugin, "examples.txt")
            if os.path.exists(examples_file):
                for line in open(examples_file):
                    line = line.strip()
                    if line.startswith('!'):
                        if line == '!always_invoke':
                            plugins_to_always_invoke.add(plugin_name)
                        elif line.startswith('!regex '):
                            _, field_name, regex = line.split(' ', 2)
                            regexes[field_name[1:]] = regex
                    elif len(line):
                        example_phrases.append(parse_example_to_phrase(plugin_name, line))

def parse_query(query):
    parsed = commanding.parse_phrase(query, example_phrases, regexes)
    if parsed == None or parsed.intent == '':
        return None
    return {"plugin": parsed.intent, "arguments": parsed.tags()}

if __name__=='__main__':
    query = sys.argv[1]
    plugins_to_invoke = set(plugins_to_always_invoke)
    parsed = parse_query(query)
    print parsed
    if parsed != None:
        plugins_to_invoke.add(parsed['plugin'])
    
    results = {}
    for plugin in plugins_to_invoke:
        plugin_path = os.path.join(plugin_dir, plugin+'.bundle', 'plugin.py')
        with WorkingDirAs(os.path.split(plugin_path)[0]):
            plugin_module = imp.load_source(plugin_name, plugin_path)
            args = parsed['arguments'] if parsed and parsed['plugin'] == plugin else None
            res = plugin_module.results(args, query) # can return a dict or a list of result dicts
            if type(res) == dict:
                results[plugin] = [res]
            elif type(res) == list:
                results[plugin] = res
    
    print json.dumps(results)
