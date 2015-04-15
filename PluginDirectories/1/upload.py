import sys, requests, hashlib, zipfile, urllib2, StringIO, json, compute_version, os

def get_plugin_name(data):
  file = StringIO.StringIO(data)
  archive = zipfile.ZipFile(file)
  has_info = False
  for name in archive.namelist():
    if name.endswith('/info.json'):
      data = json.load(archive.open(name))
      return data['name']

zip_file = sys.argv[1]
console_key = sys.argv[2]
bundle_path = os.path.splitext(zip_file)[0] + '.bundle'

data = open(zip_file, 'rb').read()
name = get_plugin_name(data)
print "Uploading plugin:", name

host = 'localhost:24080' if '--local' in sys.argv else 'flashlightplugins.appspot.com'

info = requests.get('http://{0}/console_upload/{1}'.format(host, name.encode('utf-8'))).json()
print info['version']
disk_version, _ = compute_version.get_version(bundle_path)
print disk_version
if info['version'] == disk_version:
	print "Same version of plugin already on server."
	quit()

import time
time.sleep(0.5)


# via http://stackoverflow.com/questions/17294507/google-app-engine-error-uploading-file-to-blobstore-from-python-code
# no idea why vanilla requests doesn't work

def encode_multipart_formdata(fields, files, mimetype='image/png'):
	boundary = 'paLp12Buasdasd40tcxAp97curasdaSt40bqweastfarcUNIQUE_STRING'
	crlf = '\r\n'
	line = []
	for (key, value) in fields:
	  line.append('--' + boundary)
	  line.append('Content-Disposition: form-data; name="%s"' % key)
	  line.append('')
	  line.append(value)
	for (key, filename, value) in files:
	  line.append('--' + boundary)
	  line.append('Content-Disposition: form-data; name="%s"; filename="%s"' % (key, filename))
	  line.append('Content-Type: %s' % mimetype)
	  line.append('')
	  line.append(value)
	line.append('--%s--' % boundary)
	line.append('')
	body = crlf.join(line)
	content_type = 'multipart/form-data; boundary=%s' % boundary
	return content_type, body


ct, bd = encode_multipart_formdata([("console_key", console_key)], [("zip", "zip.zip", data)])
print requests.post(info['upload_url'], data=bd, headers={"Content-Type": ct}).text

