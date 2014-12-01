import os, sys, cPickle as pickle, datetime, tempfile, shutil

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

def get_cached_data_structure(cache_path, max_age, creation_fn):
  if os.path.exists(cache_path):
    file_age = datetime.datetime.now() - datetime.datetime.fromtimestamp(os.path.getmtime(cache_path))
    if file_age < datetime.timedelta(seconds=max_age):
      try:
        data = pickle.load(open(cache_path, 'rb'))
        return data
      except Exception:
        pass
  data = creation_fn()
  file_handle, path = tempfile.mkstemp()
  file = os.fdopen(file_handle, "wb")
  pickle.dump(data, file)
  os.fsync(file)
  file.close()
  shutil.move(path, cache_path)
  return data
