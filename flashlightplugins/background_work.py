import webapp2
from search import UpdateSearchRanks

app = webapp2.WSGIApplication([('/__background_work/update_search_ranks', UpdateSearchRanks)], debug=True)
