import sys, json
input = json.loads(sys.argv[1])
sys.path.append(input['builtinModulesPath'])
import plugin
plugin.run(*input['runArgs'])
