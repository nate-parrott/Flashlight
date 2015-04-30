import webapp2
from google.appengine.ext import ndb
import json
from google_measurement_protocol import Event, report

class Action(ndb.Expando):
	action = ndb.StringProperty()
	user = ndb.StringProperty()
	date = ndb.DateTimeProperty(auto_now_add=True)

class LogHandler(webapp2.RequestHandler):
	def post(self):
		payload = json.loads(self.request.body)
		
		event = Event('spotlight', payload.get('action', 'unknown'))
		report('UA-37604830-8', payload.get('user', None), event)
		
		"""a = Action(
			user = payload.get('user', None),
			action = payload.get('action', None)
		)
		a.put()"""
		self.response.write("okay")
