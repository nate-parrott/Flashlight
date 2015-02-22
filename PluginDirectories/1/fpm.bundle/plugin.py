def results(fields, original_query):
  id = fields['~id']
  parsed = id.split('/')
  html = open("js.html").read().replace("{USER}", parsed[0]).replace("{REPO}", parsed[1])
  return {
    "title": "Flashpm '{0}'".format(id),
    "run_args": [id],
    "html": html
  }

def run(id):
    parsed = id.split('/')
    from subprocess import Popen
    Popen(['./download.sh', 'https://github.com/{0}/{1}/archive/master.zip'.format(parsed[0], parsed[1]), parsed[1]])

if __name__=='__main__':
  run("mmarcon/flashlight-test-plugin")
