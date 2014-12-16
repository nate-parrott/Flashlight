import webapp2
from google.appengine.ext import ndb
from model import Plugin
import search


class CleanUp(webapp2.RequestHandler):
    def get(self):
        self.response.write("<form method='post'><input type='submit'/></form>")

    def post(self):
        aggregate_download_counts()
        ensure_documents_indexed()
        remove_duplicates()
        self.response.write("Done.")


def aggregate_download_counts():
    names = set()
    for plugin in Plugin.query(Plugin.approved is False):
        names.add(plugin.name)
    for name in names:
        plugins = list(Plugin.query(Plugin.name == name))
        total = sum([plugin.downloads for plugin in plugins])
        any_approved = len([p for p in plugins if p.approved]) > 0
        if any_approved:
            for p in plugins:
                p.downloads = total if p.approved else 0
                p.put()


def ensure_documents_indexed():
    for plugin in Plugin.query(Plugin.approved is True):
        search.ensure_plugin_indexed(plugin)


def remove_duplicates():
    plugins = list(Plugin.query().fetch())
    versions_to_keep = {}
    for plugin in plugins:
        if plugin.approved:
            if plugin.name not in versions_to_keep or plugin.added > \
                    versions_to_keep[plugin.name].added:
                versions_to_keep[plugin.name] = plugin
    for plugin in plugins:
        if plugin.approved and plugin.name in versions_to_keep and plugin != \
                versions_to_keep[plugin.name]:
            plugin.approved = False
            plugin.put()


app = webapp2.WSGIApplication([('/cleanup', CleanUp)], debug=True)
