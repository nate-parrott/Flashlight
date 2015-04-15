from secret_config import secret_config
from bing_search_api import BingSearchAPI

search_api = BingSearchAPI(secret_config['BING_API_KEY'])

def query(q, sources='web'):
	params = {"$format": "json", "$top": 20}
	response = search_api.search(sources, q.encode('utf-8'), params)
	return response.json()
