
def results(parsed, original_query, obj):
    dict = {
        "title": "Send an iMessage",
        "run_args": [obj.multitags()],
        "html": html(obj.multitags()),
        "webview_transparent_background": True
    }
    return dict


def html(parsed):
    recips = parsed.get('~_PersonalName', [])
    body = parsed.get('~message', [''])[0]
    attach = "<img src='paper-clip.png'/> Any files currently selected in Finder will be attached." if 'include_files' in parsed else ""
    return open('html.html').read().replace("<!--RECIPIENTS-->", ", ".join(recips)).replace("<!--BODY-->", body).replace("<!--ATTACH-->", attach)

def run(parsed):
    recips = parsed.get('~_PersonalName', [])
    if len(recips) != 1: return
    recip = recips[0]
    body = parsed.get('~message', [''])[0]
    attach = 'include_files' in parsed
    from send_message import send_message
    send_message(recip, body, attach)
