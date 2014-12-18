def results(parsed, original):
  import json
  html = """
  <style>
  #logo {
    position: absolute;
    right: 10px;
    bottom: 10px;
    background-color: white;
    border-radius: 50%;
    box-shadow: 0px 1px 2px gray;
    padding: 10px;
    display: block;
  }
  #logo img {
    height: 13px;
    padding-top: 11px;
    padding-bottom: 11px;
    display: block;
  }
  html, body {
    height: 100%;
    width: 100%;
    font-family: sans-serif;
    margin: 0;
  }
  #centered {
    display: table;
    width: 100%;
    height: 100%;
  }
  #centered > div {
    display: table-cell;
    vertical-align: middle;
    text-align: center;
  }
  #centered > div > div#content {
    display: inline-block;
    max-width: 80%;
    font-size: x-large;
    text-align: center;
    font-weight: 100;
  }
  #loading {
    font-style: italic;
  }
  #content img {
    max-width: 100%;
  }
  </style>
  
  <a id='logo' href='http://giphy.com'>
    <img src='logo.gif'/>
  </a>
  
  <div id='centered'>
    <div>
      <div id='content'>
        <div id='loading'>Loading...</div>
      </div>
    </div>
  </div>
  
  <script src='jquery.min.js'></script>
  <script>
  GIF = null;
  var query = <!--QUERY-->;
  setTimeout(function() {
    $.ajax({
      url: "http://api.giphy.com/v1/gifs/translate?api_key=5xaOcLLcLRDc8fQDACk&rating=pg-13&s=" + encodeURIComponent(query),
      success: function(response) {
        var data = response.data;
        if (data.length == 0) {
           $("#content").text("No results.");
        } else {
          GIF = data;
           var url = GIF.images.fixed_height_downsampled.url;
           $("#content").empty().append($("<img/>").attr({src: url}));
        }
      }
    })
  }, 500);
  
  function output() {
     return GIF.images.original.url;
  }
  </script>
  """.replace("<!--QUERY-->", json.dumps(parsed['~query']))
  return {
    "title": u"\"{0}\" GIFs (Press enter to copy)".format(parsed['~query']),
    "html": html,
    "pass_result_of_output_function_as_first_run_arg": True,
    "run_args": ["abc"],
    "webview_transparent_background": True,
    "webview_links_open_in_browser": True
  }

def run(result, abc):
  from copy_to_clipboard import copy_to_clipboard
  from post_notification import post_notification
  if result:
    copy_to_clipboard(result)
    post_notification("Copied GIF URL.")
