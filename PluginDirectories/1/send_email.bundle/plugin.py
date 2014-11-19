import os

def is_valid_command(name):
    import subprocess
    whereis = subprocess.Popen(['whereis', name], stdout=subprocess.PIPE, stdin=subprocess.PIPE)
    return len(whereis.communicate("")[0]) > 0

def results(parsed, original_query, obj):
    dict = {
        "title": "Send an email",
        "run_args": [obj.multitags()],
        "html": html(obj.multitags()),
        "webview_transparent_background": True
    }
    return dict

def process_recip(name):
    return name.replace(' ', '') if '@' in name else name

def html(parsed):
    recips = map(process_recip, parsed.get('~_PersonalName', []))
    subject = parsed.get('~subject', [''])[0]
    body = parsed.get('~message', [''])[0]
    attach = "<img src='paper-clip.png'/> Any files currently selected in Finder will be attached." if 'include_files' in parsed else ""
    return open('html.html').read().replace("<!--RECIPIENTS-->", ", ".join(recips)).replace("<!--SUBJECT-->", subject).replace("<!--BODY-->", body).replace("<!--ATTACH-->", attach)

def run(parsed):
    recips = map(process_recip, parsed.get('~_PersonalName', []))
    subject = parsed.get('~subject', [''])[0]
    body = parsed.get('~message', [''])[0]
    attach = 'include_files' in parsed
    from send_mail import send_mail
    send_mail(recips, subject, body, attach)
