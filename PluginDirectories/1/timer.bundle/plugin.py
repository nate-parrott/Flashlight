import os, json, pipes, time, math

def secToText(sec):
    minute = math.floor(sec / 60)
    second = sec - minute * 60
    if (minute < 1):
        return "%s seconds" % int(second)
    else:
        return "%s minutes and %s seconds" % (int(minute), int(second))

def post_notification(message, title="Flashlight"):
    # do string escaping:
    message = json.dumps(message)
    title = json.dumps(title)
    script = 'display notification {0} with title {1}'.format(message, title)
    os.system("osascript -e {0}".format(pipes.quote(script)))

def playAudio(fileName = "beep.wav", repeat=3):
    for i in range(repeat):
        os.system("afplay %s" % fileName)

def notifyAlert(timeout, sound = True):
    time.sleep(timeout)
    post_notification("Timer for %s finished" % secToText(timeout), "Times up!")
    if sound:
        playAudio()

def convertToSeconds(s, m=0, h=0, d=0):
    return (s + m * 60 + h * 3600 + d * 86400)

def parseTime(timeString):
    try:
        colonIndex = timeString.find(":")
        minuteIndex = timeString.find("m")
        secondIndex = timeString.find("s")
        if (colonIndex > -1):
            minute = timeString[:colonIndex]
            second = timeString[(colonIndex + 1):]
        elif (minuteIndex > -1 and secondIndex > -1):
            minute = timeString[:minuteIndex]
            second = timeString[(minuteIndex + 1):secondIndex]
        elif (minuteIndex > -1):
            minute = timeString[:minuteIndex]
            second = 0
        elif (secondIndex > -1):
            minute = 0
            second = timeString[:minuteIndex]
        else:
            minute = 0
            second = timeString
        second = int(second)
        minute = int(minute)
        return convertToSeconds(second, minute)
    except:
        return -1

def results(fields, original_query):
    time = fields['~time']
    timeInSecond = parseTime(time)
    return {
        "title": "Set a timer for %s" % secToText(timeInSecond),
        "run_args": [timeInSecond],  # ignore for now
    }

def run(time):
    notifyAlert(time)