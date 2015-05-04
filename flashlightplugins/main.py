#!/usr/bin/env python

import urllib
import urllib2
import zipfile
import StringIO
import json
import os
import base64
import hashlib
import webapp2
from google.appengine.ext import blobstore
from util import *
from google.appengine.ext.webapp import blobstore_handlers
from file_storage import upload_file_and_get_url
from google.appengine.api import images
from google.appengine.api import memcache
from google.appengine.api import users
import bs4
import model
from model import Plugin, total_plugins_count
from directory import directory_html, info_dict_for_plugin
from util import get_localized_key
import query_updates
from applogging import LogHandler
from stats import StatsHandler

def send_upload_form(request, message=None):
		request.response.write(template("upload.html",
																		{"upload_url": blobstore.create_upload_url('/post_upload'),
																		 "message": message,
																		 "admin": users.is_current_user_admin()}))

class PreviewHandler(webapp2.RequestHandler):
		def get(self):
				self.response.write(template("index2.html"))

class MainHandler(webapp2.RequestHandler):
		def get(self):
			key = 'main.MainHandler.rendered'
			rendered = memcache.get(key)
			if not rendered:
				rendered = self.render()
				memcache.set(key, rendered, time=60)
			self.response.write(rendered)
				
		def render(self):
				args = {
					"featured_html": directory_html(category='Featured', browse=True),
					"plugins_count_rounded": int(total_plugins_count() / 10) * 10
				}
				return template("index.html", args)

class UploadHandler(webapp2.RequestHandler):
		def get(self):
				send_upload_form(self)


def resize_and_store(data, size):
		img = images.Image(data)
		img.resize(size, size)
		data = img.execute_transforms(output_encoding=images.PNG)
		return upload_file_and_get_url(data, 'image/png')


def read_plugin_info(plugin, zip_data):
		file = StringIO.StringIO(zip_data)
		archive = zipfile.ZipFile(file)
		has_info = False
		for name in archive.namelist():
				if name.endswith('/info.json'):
						data = json.load(archive.open(name))
						plugin.name = data['name']
						plugin.info_json = json.dumps(data)
						plugin.categories = data.get('categories', ['Other'])
						has_info = True
				elif name.endswith('/Icon.png') or name.endswith('/icon.png'):
						data = archive.open(name).read()
						plugin.icon_url = resize_and_store(data, 128)
				elif name.endswith('/Screenshot.png'):
						screenshot = archive.open(name).read()
						plugin.screenshot_url = resize_and_store(screenshot, 800)
				elif name.endswith('.version'):
						plugin.version = int(name.split('/')[-1].split('.')[0])
		return has_info


class PostUploadHandler(blobstore_handlers.BlobstoreUploadHandler):
		def post(self):
				secret = self.request.get('secret', '')
				is_update = False
				if len(secret):
						plugins = Plugin.query(Plugin.secret == secret).fetch()
						if len(plugins) == 0:
								send_upload_form(self,
																 "No plugin could be found that matches that "
																 "secret.")
								return
						else:
								plugin = plugins[0]
						is_update = True
				else:
						plugin = Plugin()
				plugin.zip_url = 'http://' + os.environ['HTTP_HOST'] + '/serve/' + str(
						self.get_uploads('zip')[0].key())
				zip_data = urllib2.urlopen(plugin.zip_url).read()
				if not read_plugin_info(plugin, zip_data):
						send_upload_form(self,
														 "We couldn't find a valid info.json file in your "
														 "zip.")
						return

				console_key = self.request.get('console_key', None)

				plugin.secret = base64.b64encode(os.urandom(128))
				plugin.notes = self.request.get('notes', '')

				admin = users.is_current_user_admin() or \
						(console_key and console_key_is_valid(console_key))
				if admin:
						existing = Plugin.by_name(plugin.name)
						if existing:
								plugin.downloads += existing.downloads
								plugin.put()
								existing.disable()
								existing.downloads = 0
								existing.put()
				plugin.put()
				if admin:
						plugin.enable()

				if console_key is not None:
						self.response.write({"success": True})
				else:
						approval_msg = " It'll be public after it's been approved." if not is_update else ""
						message = "Your plugin was uploaded!" + approval_msg
						self.response.write(template("uploaded.html", {"message": message,
																													 "plugin": plugin}))


class Directory(webapp2.RequestHandler):
		def get(self):
				languages = self.request.get('languages', '').split(',') + ['en'] if self.request.get('languages') else None
				category = self.request.get('category', None)
				search = self.request.get('search', None)
				browse = self.request.get('browse', '') != ''
				name = self.request.get('name', None)
				deep_links = self.request.get('deep_links', None) != None
				self.response.write(directory_html(category, search, languages, browse, name, deep_links=deep_links))


class ServeHandler(blobstore_handlers.BlobstoreDownloadHandler):
		def get(self, resource):
				resource = str(urllib.unquote(resource))
				blob_info = blobstore.BlobInfo.get(resource)
				self.send_blob(blob_info)


def compute_categories():
		categories = set()
		for p in Plugin.query(Plugin.approved == True, projection=[Plugin.categories]):
				for c in p.categories:
						categories.add(c)
		return categories


def categories():
		categories = memcache.get("categories")
		if not categories:
				categories = compute_categories()
				memcache.set("categories", categories, time=10 * 60)	# 10 min
		return categories


class Categories(webapp2.RequestHandler):
		def get(self):
				self.response.write(json.dumps(list(categories())))


class LogInstall(webapp2.RequestHandler):
		def get(self):
				model.increment_download_count(self.request.get('name'))


class Login(webapp2.RequestHandler):
		def get(self):
				self.redirect(users.create_login_url('/'))


class LatestDownload(webapp2.RequestHandler):
		def get(self):
				url = memcache.get("download_url", None)
				if url is None:
						data = urllib2.urlopen(
								"https://raw.githubusercontent.com/nate-parrott/Flashlight/"
								"master/Appcast.xml").read()
						soup = bs4.BeautifulSoup(data)
						url = soup.find_all("enclosure")[0]["url"]
						memcache.set("download_url", url, time=60 * 10)
				self.redirect(url.encode('utf8'))


class GenerateConsoleKey(webapp2.RequestHandler):
		def post(self):
				key = base64.b64encode(os.urandom(64))
				memcache.set(key, True, time=60 * 60)
				message = "For 60 minutes, the following key will be valid for " \
									"uploading plugins via the command line:\n\n{0}".format(key)
				self.response.write(template("message.html", {"message": message}))


def console_key_is_valid(key):
		return memcache.get(key) is not None


class ConsoleUpload(webapp2.RequestHandler):
		def get(self, name):
				plugin = Plugin.by_name(name)
				version = plugin.version if plugin else None
				if not version: version = 0
				url = blobstore.create_upload_url('/post_upload')
				self.response.write(json.dumps({"version": version,
																				"upload_url": url}))


class BrowseHandler(webapp2.RequestHandler):
		def get(self):
				cats = list(sorted(categories()))
				if 'Featured' in cats:
						cats.remove('Featured')
				cats.insert(0, 'Featured')
				self.response.write(template("browse.html",
																		 {"categories": cats,
																			"initial_html": directory_html(
																					category='Featured', browse=True)}))


class PluginPageHandler(webapp2.RequestHandler):
		def get(self, name):
				plugin = Plugin.by_name(name)
				if not plugin:
						self.error(404)
						return
				localhost = 'Development' in os.environ['SERVER_SOFTWARE']
				self.response.write(template("plugin_page.html",
																		 {"plugin": info_dict_for_plugin(plugin),
																			"localhost": localhost}))

class PluginZipRedirectHandler(webapp2.RequestHandler):
	def get(self, name):
		plugin = Plugin.by_name(name)
		if not plugin:
			self.error(404)
			return
		self.redirect(plugin.zip_url.encode('utf-8'))

def Redirect(url):
	class Redir(webapp2.RequestHandler):
		def get(self):
			self.redirect(url)
	return Redir

app = webapp2.WSGIApplication([('/', MainHandler),
															 ('/preview', PreviewHandler),
															 ('/browse', BrowseHandler),
															 ('/plugin/(.+)/latest\.zip', PluginZipRedirectHandler),
															 ('/plugin/(.+)', PluginPageHandler),
															 ('/upload', UploadHandler),
															 ('/post_upload', PostUploadHandler),
															 ('/logging', LogHandler),
															 ('/directory', Directory),
															 ('/serve/(.+)', ServeHandler),
															 ('/categories', Categories),
															 ('/log_install', LogInstall),
															 ('/login', Login),
															 ('/stats', StatsHandler),
															 ('/latest_download', LatestDownload),
															 ('/query_updates', query_updates.QueryUpdatesHandler),
															 ('/feedback', Redirect("http://flashlight.42pag.es/feedback")),
								 ('/ideas', Redirect("http://ideaboardapp.appspot.com/flashlight-plugin-ideas")),
															 ('/generate_console_key', GenerateConsoleKey),
															 ('/console_upload/(.+)', ConsoleUpload)],
															debug=True)
