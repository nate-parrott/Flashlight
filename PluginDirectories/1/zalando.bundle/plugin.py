import urllib, json, i18n

def results(parsed, original_query):
    settings = json.load(open('preferences.json'))
    catgory_mapping = json.load(open('category-mapping.json'))

    country = settings.get('country')
    category = catgory_mapping[country][settings.get('category')]
    sale = settings.get('sale')
    sale_filter = ""
    if sale:
        sale_filter = "order=sale"
    prepareurl = "https://m.zalando.%s/%s?%s&q=" % (country, category, sale_filter)

    search_specs = [
        ["Zalando", "~zalandoquery", prepareurl]
    ]
    for name, key, url in search_specs:
        if key in parsed:
            url = i18n.localstr(url)
            search_key = parsed[key].encode('utf-8')
            search_url = url + urllib.quote_plus(search_key)
            if "sale" in search_key:
                search_key = search_key.replace("sale", "")
                search_url = url + urllib.quote_plus(search_key) + "&order=sale"

            return {
                "title": i18n.localstr("Suche nach '{0}' in {1}").format(search_key, category.title()),
                "run_args": [search_url],
                "html": """
                <script>
                setTimeout(function() {
                    window.location = %s
                }, 500);
                </script>
                """%(json.dumps(search_url)),
                "webview_user_agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53",
                "webview_links_open_in_browser": True
            }

def run(url):
    import os
    os.system('open "{0}"'.format(url.replace("https://m.", "https://www.")))
