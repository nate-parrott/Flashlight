import jinja2, os

JINJA_ENVIRONMENT = jinja2.Environment(
    loader=jinja2.FileSystemLoader(os.path.dirname(__file__)),
    extensions=['jinja2.ext.autoescape'],
    autoescape=True)

def template(name, vars={}):
  template = JINJA_ENVIRONMENT.get_template(name)
  return template.render(vars)