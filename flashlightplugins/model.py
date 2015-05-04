from google.appengine.ext import ndb
import search
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
    downloads = ndb.IntegerProperty(default=0)
    search_doc_id = ndb.StringProperty()
    version = ndb.IntegerProperty()

    def disable(self):
        self.approved = False
        self.put()
        search.remove_plugin_from_index(self)

    def enable(self):
        self.approved = True
        self.put()
        search.ensure_plugin_indexed(self)

    @classmethod
    def by_name(cls, name):
        plugins = Plugin.query(Plugin.name == name,
                               Plugin.approved == True).fetch()
        if len(plugins) > 0:
            return plugins[0]
        else:
            return None

def total_plugins_count():
		key = "total_plugins_count"
		count = memcache.get(key)
		if count == None:
			count = Plugin.query(Plugin.approved == True).count()
			memcache.set(key, count, 2 * 60 * 60) # cache for 2 hours
		return count

def increment_download_count(name):
    key = Plugin.by_name(name).key
    increment_download_count_by_key(key)


@ndb.transactional
def increment_download_count_by_key(key):
    plugin = key.get()
    plugin.downloads = 1 + (plugin.downloads if plugin.downloads else 0)
    plugin.put()
