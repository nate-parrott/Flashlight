import webapp2
from google.appengine.ext import ndb
import json

class Action(ndb.Expando):
	action = ndb.StringProperty()
	user = ndb.StringProperty()
	date = ndb.DateTimeProperty(auto_now_add=True)

class LogHandler(webapp2.RequestHandler):
	def post(self):
		payload = json.loads(self.request.body)
		a = Action(
			user = payload.get('user', None),
			action = payload.get('action', None)
		)
		a.put()
		self.response.write("okay")
