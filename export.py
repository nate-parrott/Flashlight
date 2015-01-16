
"""
(Incredibly hacky update deployment library)
"""

import os
import subprocess
import plistlib

info = plistlib.readPlist("FlashlightApp/EasySIMBL/Flashlight-Info.plist")
vn = info['CFBundleVersion']
v = info['CFBundleShortVersionString']

build = True
if build:
	os.system("xcodebuild -workspace FlashlightApp/Flashlight.xcworkspace -scheme Flashlight -configuration Release -archivePath ~/Desktop/Flashlight.xcarchive archive")


	os.system("xcodebuild -exportArchive -exportFormat APP -archivePath ~/Desktop/Flashlight.xcarchive -exportPath ~/Desktop/Flashlight.app")


	os.system("""pushd ~/Desktop
	zip -r Flashlight.zip Flashlight.app
	popd""")

signature = subprocess.check_output(["sh", "../Flashlight signing/sign_update.sh", os.path.expanduser("~/Desktop/Flashlight.zip"), "../Flashlight signing/dsa_priv.pem"]).strip()

import BeautifulSoup as bs
soup = bs.BeautifulSoup(open("Appcast.xml").read())
c = soup.find("channel")
item = c.find("item")
new_item = bs.BeautifulSoup(str(item))
new_item.find("title").contents = [bs.NavigableString("Version "+v)]
new_item.find("sparkle:releasenoteslink").contents = [bs.NavigableString("http://flashlightupdates.42pag.es/"+v)]
enc = new_item.find("enclosure")
enc['sparkle:version'] = vn
enc['sparkle:dsasignature'] = signature
enc['url'] = "https://github.com/nate-parrott/Flashlight/releases/download/v{0}/Flashlight.zip".format(v)
enc['sparkle:shortversionstring'] = v
c.insert(c.contents.index(item), new_item)
open("Appcast.xml", "w").write(str(soup))
