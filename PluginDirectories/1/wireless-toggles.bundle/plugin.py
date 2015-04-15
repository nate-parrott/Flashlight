import os
import i18n

def run(cmd):
	os.system(cmd)

def results(parsed, original_query):
	#Wi-Fi
	if ("wifi_on" in parsed):
		return {
			"title": i18n.localstr('Turn Wi-Fi On'),
			"run_args": ["networksetup -setairportpower en0 on"]
		}

	if ("wifi_off" in parsed):
		return {
			"title": i18n.localstr('Turn Wi-Fi Off'),
			"run_args": ["networksetup -setairportpower en0 off"]
		}

	#Bluetooth
	if ("bluetooth_on" in parsed):
		os.system("chmod +x blueutil") # it'll be un-executable after unzipping
		return {
			"title": i18n.localstr('Turn Bluetooth On'),
			"run_args": ["./blueutil on"]
		}

	if ("bluetooth_off" in parsed):
		return {
			"title": i18n.localstr('Turn Bluetooth Off'),
			"run_args": ["./blueutil off"]
		}
