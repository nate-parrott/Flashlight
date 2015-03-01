def results(fields, original_query):
  _, command, _ = original_query.split(' ')
  id = fields['~id']
  user, repo = id.split('/')
  html = open("js.html").read().replace("{USER}", user).replace("{REPO}", repo)
  return {
    "title": "Flashpm '{0}'".format(id),
    "run_args": [command, user, repo],
    "html": html
  }

def run(command, user, repo):
    from subprocess import Popen
    if command == 'install':
      Popen(['/bin/bash', './shell/install.sh', 'https://github.com/{0}/{1}/archive/master.zip'.format(user, repo), repo], close_fds = True)
    elif command == 'remove':
      Popen(['/bin/bash', './shell/remove.sh', repo], close_fds = True)

if __name__=='__main__':
  run("install", "mmarcon", "flashlight-test-plugin")
