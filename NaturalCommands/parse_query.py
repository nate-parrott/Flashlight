#!/usr/bin/python

import os
import commanding
from parse_example import parse_example_to_phrase
import sys
import json
import imp
from shared import plugin_dir, WorkingDirAs, get_cached_data_structure
import i18n
import codecs

def create_example_phrases():
    example_phrases = []
    plugins_to_always_invoke = set()
    regexes = {}

    # add baseline nonsense parses:
    example_phrases.append(commanding.Phrase("", ["ihrfeiiehrgogiheog"]))
    example_phrases.append(commanding.Phrase("", ["ihrfeio iehrgogih eog"]))
    example_phrases.append(commanding.Phrase("", ["eyfght oehrgueig erobf", ["ehheiog","hegoegn"]]))
    example_phrases.append(commanding.Phrase("", ["wurt turt gurt", ["~burt", "nurt"]]))
    example_phrases.append(commanding.Phrase("", [["~uirguieg", "hgeough egoiheroi"]]))
    example_phrases.append(commanding.Phrase("", [["~uirguieg", "hgeough egoiheroi"]]))
    example_phrases.append(commanding.Phrase("", ["what", ["~uirguieg", "hgeough egoiheroi"]]))
    example_phrases.append(commanding.Phrase("", [["~uirguieg", "hgeough egoiheroi ehgiegeg"]]))
    example_phrases.append(commanding.Phrase("", [["~uirguieg", "hgeough egoiheroi ehgiegeg riehg hierohgi"]]))
    example_phrases.append(commanding.Phrase("", [["~uirguieg", "hgeoughegoiheroi"]]))

    for plugin in os.listdir(plugin_dir):
        if os.path.isdir(os.path.join(plugin_dir, plugin)):
            plugin_name, extension = os.path.splitext(plugin)
            if extension == '.bundle':
                examples_file = os.path.join(plugin_dir, plugin, "examples.txt")
                examples_file = i18n.find_localized_path(examples_file)
                if os.path.exists(examples_file):
                    for line in codecs.open(examples_file, 'r', 'utf-8'):
                        line = line.strip()
                        if line.startswith('!'):
                            if line == '!always_invoke':
                                plugins_to_always_invoke.add(plugin_name)
                            elif line.startswith('!regex '):
                                _, field_name, regex = line.split(' ', 2)
                                regexes[field_name[1:]] = regex
                        elif len(line):
                            example_phrases.append(parse_example_to_phrase(plugin_name, line))
    
    return (example_phrases, plugins_to_always_invoke, regexes)

cache_path = os.path.join(plugin_dir, "NLPModel.pickle")
cache_max_age = 20 # 20 sec
(example_phrases, plugins_to_always_invoke, regexes) = get_cached_data_structure(cache_path, cache_max_age, create_example_phrases)

tag_processing_functions = {}

def parse_query(query, supplemental_tags):
    supplemental_tags = merge_dicts([supplemental_tags, special_tag_supplemental_examples])
    parsed = commanding.parse_phrase(query, example_phrases, regexes, supplemental_tags, tag_processing_functions)
    if parsed == None or parsed.intent == '':
        return None
    parsed = parsed.with_strings_not_unicode() # for compatibility; TODO: add flag in `info.json` to pass unicode to plugin.py instead of utf-8
    return {"plugin": parsed.intent, "arguments": parsed.tags(), "object": parsed}

def merge_dicts(dicts):
  return dict(reduce(lambda a,b: a+b, map(lambda d: d.items(), dicts)))

# import special fields:
special_tag_supplemental_examples = {}
tag_processing_functions = {}
import date_field
for special_field in [date_field]:
  tag_processing_functions[special_field.name] = special_field.transform
  special_tag_supplemental_examples[special_field.name] = special_field.examples

import inspect

if __name__=='__main__':
    query = sys.argv[1].decode('utf-8')
    plugins_to_invoke = set(plugins_to_always_invoke)
    parsed = parse_query(query, supplemental_tags=json.loads(sys.argv[2]))
    # print 'PARSED', parsed
    if parsed != None:
        plugins_to_invoke.add(parsed['plugin'])
    
    results = {}
    for plugin in plugins_to_invoke:
        plugin_path = os.path.join(plugin_dir, plugin+'.bundle', 'plugin.py')
        with WorkingDirAs(os.path.split(plugin_path)[0]):
            plugin_module = imp.load_source("plugin", plugin_path)
            args = parsed['arguments'] if parsed and parsed['plugin'] == plugin else None
            arguments = [args, query]
            if len(inspect.getargspec(plugin_module.results)[0]) == 3:
                arguments.append(parsed['object'])
            res = plugin_module.results(*arguments) # can return a dict or a list of result dicts
            if type(res) == dict:
                results[plugin] = [res]
            elif type(res) == list:
                results[plugin] = res
    
    print json.dumps(results)
