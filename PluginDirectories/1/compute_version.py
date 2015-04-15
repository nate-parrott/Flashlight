"""
Versioning is a bit complicated.
Initially, we hash the contents of each plugin's .bundle, and store that hash as 1.version 
(ignore *.version files when hashing)

Next time we want to upload files to the server, we hash again. If the hash has changed,
we delete N.version and replace it with N+1.version.
"""
import os
import hashlib

def get_version(plugin_path):
    # returns (#, hash)
    for file in os.listdir(plugin_path):
        name, ext = os.path.splitext(file)
        if ext.lower() == '.version':
            hash = open(os.path.join(plugin_path, file)).read().strip()
            return (int(name), hash)
    return (0, None)

def should_ignore_file(name):
    name = name.lower()
    if name.startswith('.'): return True
    for ext in ['.version', '.pyc']:
        if name.endswith(ext): return True
    return False
    

def hash_plugin(plugin_path):
    def hash_dir(hasher, path):
        filenames = os.listdir(path)
        filenames.sort()
        filenames = [f for f in filenames if not should_ignore_file(f)]
        hasher.update(str(filenames))
        for filename in filenames:
            child = os.path.join(path, filename)
            if os.path.isdir(child):
                hash_dir(hasher, child)
            else:
                hasher.update(open(child).read())
        return hasher
    return hash_dir(hashlib.sha256(), plugin_path).hexdigest()

def update_plugin_version(plugin_path):
    old_version, old_hash = get_version(plugin_path)
    new_hash = hash_plugin(plugin_path)
    if new_hash != old_hash:
        # remove the old version file, if there was one:
        if old_hash != None:
            os.remove(os.path.join(plugin_path, "{0}.version".format(old_version)))
        # create new version file:
        open(os.path.join(plugin_path, "{0}.version".format(old_version+1)), "w").write(new_hash)

if __name__=='__main__':
    # test:
    update_plugin_version('500px.bundle')
