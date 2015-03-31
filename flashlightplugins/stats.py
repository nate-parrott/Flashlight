import webapp2
from google.appengine.api import users
from util import template
from applogging import Action
import datetime
import random

class StatsHandler(webapp2.RequestHandler):
	def get(self):
		if users.is_current_user_admin():
			# generate_fake_data()
			self.response.write(template("stats.html", stats()))

def generate_fake_data():
	for _ in xrange(10):
		a = Action(
			user = ''.join([random.choice('abcdefg') for _ in xrange(10)]),
			action = 'viewResultFor1Sec'
		)
		a.put()

def stats():
	return {
		"dau": dau()
	}

def day_text_for_datetime(dt):
	weekdays = ['Mon', 'Tues', 'Wed', 'Thurs', 'Fri', 'Sat', 'Sun']
	return "{0}/{1}/{2} - {3}".format(dt.month, dt.day, dt.year, weekdays[dt.weekday()])

def dau():
	cutoff = datetime.datetime.now() - datetime.timedelta(days=30)
	rows = []
	
	cur_day = None
	cur_user_set = None
	def add_row():
		if cur_day:
			rows.append({"date": cur_day, "count": len(cur_user_set)})
	
	for action in Action.query(Action.date >= cutoff, Action.action == 'viewResultFor1Sec').order(-Action.date).iter(projection=[Action.date, Action.user]):
		day = day_text_for_datetime(action.date)
		if day != cur_day:
			add_row()
			cur_day = day
			cur_user_set = set()
		cur_user_set.add(action.user)
	add_row()
	
	return rows
