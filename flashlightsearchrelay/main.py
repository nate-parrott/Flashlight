#!/usr/bin/env python
#
# Copyright 2007 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#			http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
import webapp2
from query import query
from util import template

class MainHandler(webapp2.RequestHandler):
	def get(self):
		self.response.write('Hello world!')

class QueryHandler(webapp2.RequestHandler):
	def get(self, source):
		if source not in ['web', 'image', 'news']:
			self.error(404)
			return
		response = query(self.request.get('q'), sources=source)
		#self.response.write(response)
		#return
		self.response.write(template(source+'.html', {"response": response}))

app = webapp2.WSGIApplication([
		('/', MainHandler),
		('/search/(.+)', QueryHandler)
], debug=True)
