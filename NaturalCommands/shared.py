import os, sys

plugin_dir = os.path.expanduser("~/Library/FlashlightPlugins")

class WorkingDirAs(object):
	def __init__(self, dir):
		self.dir = dir
	def __enter__(self):
		self.saved_cwd = os.getcwd()
		os.chdir(self.dir)
		sys.path.append(self.dir)
	def __exit__(self, type, value, traceback):
		os.chdir(self.saved_cwd)
		sys.path.remove(self.dir)
