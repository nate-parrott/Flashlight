
name = '@date'

examples = [
  "today",
  "tomorrow",
  "yesterday",
  "tonight",
  "january 1",
  "february 2",
  "march 3",
  "april 4",
  "may 5",
  "june 6",
  "july 7",
  "august 8",
  "september 9",
  "october 10",
  "november 11",
  "december 12",
  "next monday",
  "last tuesday",
  "this wednesday",
  "thursday night",
  "friday evening",
  "saturday morning",
  "sunday afternoon",
  "monday january 21st",
  "tuesday february 23rd at 8:30",
  "tomorrow at 9:15 PM",
  "yesterday at 4 AM"
]

def transform(text):
    import parsedatetime.parsedatetime as pdt
    import time
    import datetime
    c = pdt.Calendar()
    result, what = c.parse(text)
    dt = datetime.datetime( *result[:6] )
    resolution = 60 if what == 3 else 24 * 60 * 60
    return {"timestamp": time.mktime(dt.timetuple()), "resolution": resolution, "text": text}
