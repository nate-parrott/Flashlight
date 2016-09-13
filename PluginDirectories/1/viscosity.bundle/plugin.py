import subprocess

SCRIPT = 'open_viscosity_connection.js'

def results(fields, query):
    connection = fields.get('~connection')
    if connection is None:
        connection = getFirstConnection()

    return {
        "title": "Connect to '%s' with Viscosity" % connection,
        "run_args": [connection],
    }

def run(connection):
    cmd = ['osascript', SCRIPT]
    if connection is not None:
        cmd.append(connection)

    subprocess.call(cmd)

def getFirstConnection():
    cmd = ['osascript', 'get_viscosity_connection.js']
    return subprocess.check_output(cmd).strip()
