from google.appengine.api import search
import json

search_index = search.Index(name='plugins')


def ensure_plugin_indexed(plugin):
    if plugin.search_doc_id and \
            search_index.get(plugin.search_doc_id) is not None:
        return  # it's already indexed
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
    import model

    ids = [doc.doc_id for doc in search_index.search(query)]
    if len(ids) == 0:
        return []
    plugins = list(model.Plugin.query(model.Plugin.search_doc_id.IN(ids)))
    plugins = [p for p in plugins if p.approved]
    plugins.sort(key=lambda plugin: ids.index(plugin.search_doc_id))
    return plugins
