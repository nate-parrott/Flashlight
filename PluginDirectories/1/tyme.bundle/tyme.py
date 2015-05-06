#!/usr/bin/python

from applescript import asrun, asquote
from ete2 import Tree


class Tyme(Tree):
	def run(ascript_body):
		return asrun('''tell application "Tyme"
				activate
				{}
				activate
			end tell'''.format(ascript_body))

class Project(TreeNode):
	def __init__(self, name):
		self.name = name
		self.project_name = project_name
		self.tags = tags
		create_new_task(self.name, self.project_name)
		for tag in self.tags:
			add_tag(tag)

class Task(TreeNode):
	init_script_body = '''set projectName to {0}
		if ((count of (every project whose name = projectName)) = 0) then
			make new project with properties {{name:projectName, archived:false}}
		end if
		set targetProject to first item of (every project whose name = projectName)
		make new task with properties {{name:{1}}} at the end of targetProject'''

	def __init__(self, name, project, tags):
		self.name = name if len(name) > 0 else default_name
		self.project = project
		self.tags = tags
		run_tyme_script(init_script_body.format(asquote(self.project.name), asquote(self.name)))
		for tag in self.tags:
			add_tag(tag)
		
	def create_new_task(name, project_name):
		ascript_body = '''
			set projectName to {0}
			if ((count of (every project whose name = projectName)) = 0) then
				make new project with properties {{name:projectName, archived:false}}
			end if
			set targetProject to first item of (every project whose name = projectName)
			make new task with properties {{name:{1}}} at the end of targetProject
			'''.format(asquote(self.project_name), asquote(self.name))
		return run_tyme_script(ascript_body)

	def add_tag(tag):
		self.tags.append(tag)
		ascript_body = '''
			set targetProject to first item of (every project whose name = {0})
			set targetTask to first item of (every task of targetProject whose name = {1})
			make new taskTag with properties {{name:{2}}} at the end of targetTask
			'''.format(asquote(self.project_name), asquote(self.name), asquote(tag))
		run_tyme_script(ascript_body)

