import cloudstorage as gcs
from google.appengine.api import app_identity
import os
import uuid


def upload_file_and_get_url(data, mimetype='application/octet-stream'):
    bucket_name = os.environ.get('BUCKET_NAME',
                                 app_identity.get_default_gcs_bucket_name())
    filename = uuid.uuid4().hex
    write_retry_params = gcs.RetryParams(backoff_factor=1.1)
    gcs_file = gcs.open('/' + bucket_name + '/' + filename,
                        'w',
                        content_type=mimetype,
                        options={'x-goog-acl': 'public-read'},
                        retry_params=write_retry_params)
    gcs_file.write(data)
    gcs_file.close()
    return "https://storage.googleapis.com/{0}/{1}".format(bucket_name,
                                                           filename)
