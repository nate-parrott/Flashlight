#!/usr/bin/env python

import pypsum
import gtk
import gtk.glade
import gobject
import os

class PypsumGTK:
	
	what = ('paras', 'words', 'bytes', 'lists')
	
	def __init__(self):
		self.glade = gtk.glade.XML('pypsum.glade')
		signals = {
			'main-delete': self.quit,
			'generate'   : self.generate,
			'copy'       : self.copy
		}
		self.glade.signal_autoconnect(signals)
		self.glade.get_widget('what').set_active(0)
		gtk.main()
	
	def generate(self, widget=None, data=None):
		buf = gtk.TextBuffer()
		buf.set_text("Please wait...")
		self.glade.get_widget('lipsum').set_buffer(buf)
		gobject.idle_add(self.do_generate)
	
	def do_generate(self):
		howmany = int(self.glade.get_widget('howmany').get_text())
		what = self.what[self.glade.get_widget('what').get_active()]
		start_with = 'yes' if self.glade.get_widget('start_with').get_active() else 'no'
		lipsum = pypsum.get_lipsum(howmany, what, start_with)
		buf = gtk.TextBuffer()
		buf.set_text(lipsum[0])
		self.glade.get_widget('lipsum').set_buffer(buf)
		self.glade.get_widget('generated').set_text(lipsum[1])
	
	def copy(self, widget=None, data=None):
		text = self.glade.get_widget('lipsum').get_buffer().get_text(
			self.glade.get_widget('lipsum').get_buffer().get_start_iter(),
			self.glade.get_widget('lipsum').get_buffer().get_end_iter(),
			False
		)
		clipboard = gtk.Clipboard()
		clipboard.set_text(text)
	
	def quit(self, widget=None, data=None):
		gtk.main_quit()

if __name__ == '__main__':
	os.chdir(os.path.dirname(os.path.realpath(__file__)))
	PypsumGTK()
