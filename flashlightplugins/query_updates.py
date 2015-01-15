import webapp2
import json
from model import Plugin

class QueryUpdatesHandler(webapp2.RequestHandler):
	def post(self):
		plugins_by_version = json.loads(self.request.body)
		plugins = Plugin.query(Plugin.name.IN(plugins_by_version.keys())).fetch()
		needs_update = [p.name for p in plugins if p.version and p.version > plugins_by_version[p.name]]
		self.response.write(json.dumps({"plugins": needs_update}))
