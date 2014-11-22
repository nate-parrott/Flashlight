#!/usr/bin/env python
#
# Copyright 2007 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
import webapp2
from google.appengine.ext import ndb
from google.appengine.ext import blobstore
from util import *
from google.appengine.ext.webapp import blobstore_handlers
import urllib, urllib2
import os
import base64
from google.appengine.api.images import get_serving_url
import zipfile
import StringIO
import json
from file_storage import upload_file_and_get_url
import os
from google.appengine.api import images
from google.appengine.api import memcache

class Plugin(ndb.Model):
  info_json = ndb.TextProperty()
  categories = ndb.StringProperty(repeated=True)
  name = ndb.StringProperty()
  zip_url = ndb.StringProperty()
  added = ndb.DateTimeProperty(auto_now_add=True)
  approved = ndb.BooleanProperty(default=False)
  secret = ndb.StringProperty()
  notes = ndb.TextProperty()
  icon_url = ndb.StringProperty()
  screenshot_url = ndb.StringProperty()

def send_upload_form(request, message=None):
  request.response.write(template("upload.html", {"upload_url": blobstore.create_upload_url('/post_upload'), "message": message}))

class MainHandler(webapp2.RequestHandler):
    def get(self):
        self.redirect('/upload')

class UploadHandler(webapp2.RequestHandler):
  def get(self):
    send_upload_form(self)

def resize_and_store(data, size):
  img = images.Image(data)
  img.resize(size, size)
  data = img.execute_transforms(output_encoding=images.PNG)
  return upload_file_and_get_url(data, 'image/png')

def read_plugin_info(plugin):
  file = StringIO.StringIO(urllib2.urlopen(plugin.zip_url).read())
  archive = zipfile.ZipFile(file)
  has_info = False
  for name in archive.namelist():
    print name
    if name.endswith('/info.json'):
      data = json.load(archive.open(name))
      plugin.name = data['name']
      plugin.info_json = json.dumps(data)
      plugin.categories = data.get('categories', ['Other'])
      has_info = True
    elif name.endswith('/Icon.png'):
      data = archive.open(name).read()
      plugin.icon_url = resize_and_store(data, 128)
    elif name.endswith('/Screenshot.png'):
      screenshot = archive.open(name).read()
      plugin.screenshot_url = resize_and_store(data, 600)
  return has_info

class PostUploadHandler(blobstore_handlers.BlobstoreUploadHandler):
  def post(self):
    secret = self.request.get('secret')
    is_update = False
    if len(secret):
      plugins = Plugin.query(Plugin.secret == secret).fetch()
      if len(plugins) == 0:
        send_upload_form(self, "No plugin could be found that matches that secret.")
        return
      else:
        plugin = plugins[0]
      is_update = True
    else:
      plugin = Plugin()
    plugin.zip_url = 'http://' + os.environ['HTTP_HOST'] + '/serve/' + str(self.get_uploads('zip')[0].key())
    if not read_plugin_info(plugin):
      send_upload_form(self, "We couldn't find a valid info.json file in your zip.")
      return
    plugin.secret = base64.b64encode(os.urandom(128))
    plugin.notes = self.request.get('notes')
    plugin.put()
    approval_msg = " It'll be public after it's been approved." if not is_update else ""
    message = "Your plugin was uploaded!" + approval_msg
    self.response.write(template("uploaded.html", {"message": message, "plugin": plugin}))

class Directory(webapp2.RequestHandler):
  def get(self):
    category = self.request.get('category')
    plugins = []
    for p in Plugin.query(Plugin.categories == category, Plugin.approved == True):
      plugin = json.loads(p.info_json)
      plugin['model'] = p
      plugins.append(plugin)
    self.response.write(template("directory.html", {"plugins": plugins}))

class ServeHandler(blobstore_handlers.BlobstoreDownloadHandler):
  def get(self, resource):
    resource = str(urllib.unquote(resource))
    blob_info = blobstore.BlobInfo.get(resource)
    self.send_blob(blob_info)

def compute_categories():
    categories = set()
    for p in Plugin.query():
      for c in p.categories:
        categories.add(c)
    return categories

class Categories(webapp2.RequestHandler):
  def get(self):
    categories = memcache.get("categories")
    if not categories:
      categories = compute_categories()
      memcache.set("categories", categories, time=10 * 60) # 10 min
    self.response.write(json.dumps(list(categories)))

app = webapp2.WSGIApplication([
    ('/', MainHandler),
    ('/upload', UploadHandler),
    ('/post_upload', PostUploadHandler),
    ('/directory', Directory),
    ('/serve/(.+)', ServeHandler),
    ('/categories', Categories)
], debug=True)
