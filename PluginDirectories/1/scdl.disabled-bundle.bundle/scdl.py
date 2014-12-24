#! /usr/bin/env python
 
# usage : python scdl.py <soundcloud track/playlist url>
 
import soundcloud
import urllib
import re
import time
import os
import sys

from mutagen.mp3 import MP3
from mutagen.id3 import ID3, APIC, error
 
CLIENT_ID = '49009eb8904b11a2a5d2c6bdc162dd32'
MEDIA_STREAM_URL = 'http://media.soundcloud.com/stream/'

# color codes for terminal output
class colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    END = '\033[0m'

class scdl:
	client = soundcloud.Client(client_id=CLIENT_ID)
 
	def __init__(self, url, download_path, silent=True):
		self.url = url
		self.download_progress = 0
		self.download_path = os.path.expanduser(download_path)
		self.current_time = time.time()
		self.track_url_dicts = self.resolve(url)
		self.silent = silent
 
	# resolve a Soundcloud URL 
	# return track details in list (i.e. if only a single song, 
	#	a single element list will be returned)
	def resolve(self, url):
		returnMedia = []
		resolved_url = self.client.get('/resolve', url=url);
		if resolved_url.kind == 'track':
			# resolved_url is a single track object 
			returnMedia.append(self.get_track_detail(resolved_url.id))	
		elif resolved_url.kind == 'playlist':
			# resolve_url is a list of song objects
			for track in resolved_url.tracks:
				returnMedia.append(self.get_track_detail(track['id']))
		return returnMedia
 
 	# return a dict of important attributes for a specific track
	def get_track_detail(self, track_id):
		regex = re.compile('\/([a-zA-Z0-9]+)_')
		track = self.client.get('/tracks/' + str(track_id))
		track_detail = {'title':track.title,
						# keep a version of the title that can be used as a filename
						'safe_title':re.sub('[\/:*?"<>|%]', '-', track.title),
						# find the streaming URL for this track
					 	'stream_url':MEDIA_STREAM_URL + str(regex.search(track.waveform_url).groups()[0]),
					 	# find this track's artwork URL (or substitute with the user's avatar URL)
					 	'artwork_url':(track.artwork_url if track.artwork_url else track.user['avatar_url'])}
		return track_detail

	# iterate through a list of track detail dicts and download each one
	# return a list of filenames where the tracks were downloaded to
	def dl_tracks(self, tracks):
		track_filename_list = []
		if not os.path.isdir(self.download_path):
			os.mkdir(self.download_path)
		for track in tracks:
			try:
				track_filename = self.download_path + "{0}.mp3".format(track['safe_title'])
				artwork_filename = self.download_path + ".{0}-artwork.jpg".format(track['safe_title'])
				if not self.silent: 
					sys.stdout.write(colors.HEADER + "Downloading: " + colors.END + colors.OKBLUE + "{0}".format(track['title']) + colors.END + "\n")
				urllib.urlretrieve(url=track['stream_url'], filename=track_filename, reporthook=(None if self.silent else self.dl_progress))
				# reset variables so next track's report hook doesn't malfunction
				self.download_progress = 0
				self.current_time = time.time()
				if not self.silent: 
					print
				# get the track's artwork
				urllib.urlretrieve(url=track['artwork_url'], filename=artwork_filename)
				embed_artwork(track_filename, artwork_filename)
				os.remove(artwork_filename)
				track_filename_list.append(track_filename)
			except:
				# in case of failure, just move on to next track
				continue
		return track_filename_list

	# a basic report hook that monitors a download's progress
	def dl_progress(self, block_no, block_size, file_size):
		self.download_progress += block_size
		if int(self.download_progress / 1024 * 8) > 1000:
			speed = "{0:7.2f} Mbps".format(round((self.download_progress / 1024 / 1024 * 8) / (time.time() - self.current_time), 2))
		else:
			speed = "{0:7.2f} Kbps".format(round((self.download_progress / 1024 * 8) / (time.time() - self.current_time), 2))
		rProgress = round(self.download_progress / 1024.00 / 1024.00, 2)
		rFile = round(file_size / 1024.00 / 1024.00, 2)
		percent = round(100 * float(self.download_progress) / float(file_size))
		percent = min(percent, 100)
		sys.stdout.write("\r" + colors.OKGREEN + "{3} ({0:.2f}/{1:.2f}MB): {2:6.2f}%".format(rProgress, rFile, percent, speed) + colors.END)
		sys.stdout.flush()

# takes a track's filename and it's artwork's filename and uses ID3 to embed
# 	the artwork within the track file
def embed_artwork(track_filename, artwork_filename):
	audio = MP3(track_filename, ID3=ID3)
	# add ID3 tag if it doesn't exist
	try:
	    audio.add_tags()
	except error:
	    pass
	audio.tags.add(
	    APIC(
	        encoding=3, # 3 is for utf-8
	        mime='image/jpg', # image/jpeg or image/png
	        type=3, # 3 is for the cover image
	        desc=u'Cover',
	        data=open(artwork_filename).read()
	    )
	)
	audio.save()

# easy download method to download a track specified by 'url' to a folder 'download_path'
def download(url, download_path, silent=True):
	skipper = scdl(url, download_path, silent)
	track_urls = skipper.track_url_dicts
	return skipper.dl_tracks(track_urls)

if __name__ == "__main__":
	dest = '~/Music/Soundcloud/'
	list_of_downloaded_filenames = []
	for i in range(1, len(sys.argv)):
		link = sys.argv[i]
		list_of_downloaded_filenames += download(link, dest, silent=False)
	print
	print colors.HEADER + "The following files were downloaded successfully:" + colors.END
	for i, filename in enumerate(list_of_downloaded_filenames):
		print "\t" + colors.HEADER + str(i+1) + ". " + colors.END + colors.OKBLUE + " {0}".format(filename[len(dest):]) + colors.END
	print colors.OKGREEN + "Finished." + colors.END

