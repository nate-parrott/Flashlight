import os, sys

console_key = sys.argv[1]

os.system("python generate_index.py")
for name in os.listdir('.'):
	if name.split('.')[-1] == 'zip':
		os.system("python upload.py {0} {1}".format(name, console_key))

