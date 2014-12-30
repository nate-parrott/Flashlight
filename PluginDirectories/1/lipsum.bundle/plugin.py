import pypsum

def results(fields, original_query):
    how_what = fields['~how_what']
    hw = how_what.split(' ')
    if len(hw) < 2:
        return {
                "title": "Lorem Ipsum %s ..." % hw[0]
                }
    how = hw[0]
    what = hw[1]
    lipsum = pypsum.get_lipsum(how, what, "no")
    output = lipsum[0].replace('\n', '<br /><br />')
    
    html = """
    <style>
    body {
      font-family: "HelveticaNeue";
      line-height: 1.3;
      padding: 10px;
    }
    #info {
      font-style: italic;
      font-size: small;
      opacity: 0.7;
    }
    </style>
    <p><!--OUTPUT--></p>
    <p id='info'><!--INFO-->. Press enter to copy it.</p> 
    """.replace("<!--OUTPUT-->", output).replace("<!--INFO-->", lipsum[1])
    
    return {
        "title": "Lorem Ipsum %s %s" % (how, what),
        "run_args": [output] ,
        "html": html,
        "webview_transparent_background": True,
    }

def run(output):
    import os
    #os.system('echo "'+lipsum[0]+'" | pbcopy')
    os.system('echo "'+output+'" | pbcopy')

