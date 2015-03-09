def results(fields, original_query):
  app = fields['~app']
  return {
    "title": "Kill '{0}'".format(app),
    "run_args": [app]
  }

def run(app):
  import os
  os.system('osascript -e \'quit app "{0}"\''.format(app))
