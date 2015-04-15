import os
from centered_text import centered_text

def results(fields, original_query):
	operation = None
	for op in ['move', 'copy', 'delete']:
		if op in fields:
			operation = op
	if operation:
		params = fields[operation]
		files = params.get('@file_all', [params['@file']])
		path1 = files[0]['path']
		path2 = files[1]['path'] if operation != 'delete' else TRASH
		if operation == 'copy':
			title = u"Copy {0} to {1}".format(name_for_path(path1), name_for_path(path2))
			html = centered_text(html_for_operation("copy to", path1, path2))
		elif operation == 'move':
			title = u"Move {0} to {1}".format(name_for_path(path1), name_for_path(path2))
			html = centered_text(html_for_operation("move to", path1, path2))
		elif operation == 'delete':
			title = u"Delete {0}".format(name_for_path(path1))
			html = centered_text(html_for_operation("move to", path1, path2))
		return {
			"title": title,
			"html": html,
			"webview_transparent_background": True,
			"run_args": [operation, path1, path2]
		}

TRASH = "$TRASH"

def html_for_operation(operation, file1, file2):
	return u"""
	<div class='operation'>
	{0}
	<h1>{1}</h1>
	{2}
	</div>
	""".format(html_for_path(file1), operation, html_for_path(file2))

def name_for_path(path):
	return os.path.split(path)[1] if path != TRASH else "Trash"

def html_for_path(path):
	if path == TRASH:
		icon = 'Trash.png'
	elif os.path.isdir(path):
		icon = 'Folder.png'
	else:
		icon = 'File.png'
	name = os.path.split(path)[1]
	if path == TRASH: name = 'Trash'
	path_html = "<p>{0}</p>".format(path)
	if path == TRASH: path_html = ""
	return u"""
	<div class='file'>
		<div><img src='Images/{0}'/></div>
		<div>
			<h2>{1}</h2>
			{2}
		</div>
	</div>
	""".format(icon, name, path_html)

def run(op, src, dest):
	import AppKit as ns
	dir, file = os.path.split(src)
	if op == 'delete':
		ns.NSWorkspace.sharedWorkspace().performFileOperation_source_destination_files_tag_(ns.NSWorkspaceRecycleOperation, dir, "", [file], None)
	elif op in ('move', 'copy'):
		if not os.path.isdir(dest):
			dest = os.path.split(dest)[0]
		operation = ns.NSWorkspaceMoveOperation if op == 'move' else ns.NSWorkspaceCopyOperation
		ns.NSWorkspace.sharedWorkspace().performFileOperation_source_destination_files_tag_(operation, dir, dest, [file], None)
