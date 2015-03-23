import os, sys, pipes
from multiprocessing import Pool

console_key = sys.argv[1]

def upload(name):
	if name.split('.')[-1] == 'zip':
		os.system("python upload.py {0} {1}".format(pipes.quote(name), console_key))

os.system("python generate_index.py")
p = Pool(4)
p.map(upload, os.listdir('.'))
