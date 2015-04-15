from google.appengine.api import search
import json
import webapp2
import model

search_index = search.Index(name='plugins')


def ensure_plugin_indexed(plugin):
		if plugin.search_doc_id and \
						search_index.get(plugin.search_doc_id) is not None:
				return	# it's already indexed
		fields = []
		info = json.loads(plugin.info_json)
		indexable_field_names = ["displayName", "description", "search_keywords",
														 "examples", "categories"]
		for field, vals in info.iteritems():
				for indexable in indexable_field_names:
						if field.startswith(indexable):
								if type(vals) != list:
										vals = [vals]
								for val in vals:
										fields.append(search.TextField(name=field, value=val))

		doc = search.Document(fields=fields)
		plugin.search_doc_id = search_index.put(doc)[0].id
		plugin.put()


def remove_plugin_from_index(plugin):
		doc_id = plugin.search_doc_id
		if doc_id:
				doc = search_index.get(doc_id)
				if doc:
						search_index.delete([doc_id])
		plugin.search_doc_id = None
		plugin.put()


def search_plugins(query):
		ids = [doc.doc_id for doc in search_index.search(query)]
		if len(ids) == 0:
				return []
		plugins = list(model.Plugin.query(model.Plugin.search_doc_id.IN(ids)))
		plugins = [p for p in plugins if p.approved]
		plugins.sort(key=lambda plugin: ids.index(plugin.search_doc_id))
		return plugins

class UpdateSearchRanks(webapp2.RequestHandler):
	def get(self):
		batch_size = 30
		last_id = None
		print "UPDATE SEARCH RANKS"
		while True:
			docs = search_index.get_range(limit=batch_size, include_start_object=False, start_id=last_id)
			if len(docs) == 0:
				print "DONE"
				break
			ids = [doc.doc_id for doc in docs]
			last_id = ids[-1]
			plugins = list(model.Plugin.query(model.Plugin.search_doc_id.IN(ids)))
			plugins_by_doc_id = {p.search_doc_id: p for p in plugins if p.approved}
			new_docs = []
			for doc in docs:
				plugin = plugins_by_doc_id.get(doc.doc_id)
				if plugin and doc.rank != plugin.downloads:
					new_docs.append(search.Document(doc_id = doc.doc_id, fields = doc.fields, rank=plugin.downloads))
			print "UPDATING", len(new_docs)
			if len(new_docs):
				search_index.put(new_docs)

