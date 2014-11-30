from google.appengine.api import search
import json

search_index = search.Index(name='plugins')

def ensure_plugin_indexed(plugin):
  if plugin.search_doc_id and search_index.get(plugin.search_doc_id) != None:
    return # it's already indexed
  info = json.loads(plugin.info_json)
  
  fields = []
  fields.append(search.TextField(name='displayName', value=info['displayName']))
  if 'description' in info:
    fields.append(search.TextField(name='description', value=info['description']))
  if 'search_keywords' in info:
    fields.append(search.TextField(name='search_keywords', value=info['search_keywords']))
  for example in info.get('examples', []):
    fields.append(search.TextField(name='example', value=example))
  for category in info.get('categories', []):
    fields.append(search.TextField(name='category', value=category))
  
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
