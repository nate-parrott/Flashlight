
"""
Test parsing of simple date and times
"""

import unittest, time, datetime
import parsedatetime as pdt


  # a special compare function is used to allow us to ignore the seconds as
  # the running of the test could cross a minute boundary
def _compareResults(result, check):
    target, t_flag = result
    value,  v_flag = check

    t_yr, t_mth, t_dy, t_hr, t_min, _, _, _, _ = target
    v_yr, v_mth, v_dy, v_hr, v_min, _, _, _, _ = value

    return ((t_yr == v_yr) and (t_mth == v_mth) and (t_dy == v_dy) and
            (t_hr == v_hr) and (t_min == v_min)) and (t_flag == v_flag)


class test(unittest.TestCase):
    def setUp(self):
        self.cal = pdt.Calendar()
        self.yr, self.mth, self.dy, self.hr, self.mn, self.sec, self.wd, self.yd, self.isdst = time.localtime()

    def testDays(self):
        s = datetime.datetime.now()
        t = s + datetime.timedelta(days=1)

        start  = s.timetuple()
        target = t.timetuple()

        d = self.wd + 1

        if d > 6:
            d = 0

        day = self.cal.ptc.Weekdays[d]

        self.assertTrue(_compareResults(self.cal.parse(day, start), (target, 1)))

        t = s + datetime.timedelta(days=6)

        target = t.timetuple()

        d = self.wd - 1

        if d < 0:
            d = 6

        day = self.cal.ptc.Weekdays[d]

        self.assertTrue(_compareResults(self.cal.parse(day, start), (target, 1)))

    def testTimes(self):
        start  = datetime.datetime(self.yr, self.mth, self.dy, self.hr, self.mn, self.sec).timetuple()
        target = datetime.datetime(self.yr, self.mth, self.dy, 23, 0, 0).timetuple()

        self.assertTrue(_compareResults(self.cal.parse('11:00:00 PM',   start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('11:00 PM',      start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('11 PM',         start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('11PM',          start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('2300',          start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('23:00',         start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('11p',           start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('11pm',          start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('11:00:00 P.M.', start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('11:00 P.M.',    start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('11 P.M.',       start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('11P.M.',        start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('11p.m.',        start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('11 p.m.',       start), (target, 2)))

        target = datetime.datetime(self.yr, self.mth, self.dy, 11, 0, 0).timetuple()

        self.assertTrue(_compareResults(self.cal.parse('11:00:00 AM', start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('11:00 AM',    start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('11 AM',       start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('11AM',        start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('1100',        start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('11:00',       start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('11a',         start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('11am',        start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('11:00:00 A.M.', start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('11:00 A.M.',    start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('11 A.M.',       start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('11A.M.',        start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('11a.m.',        start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('11 a.m.',       start), (target, 2)))

        target = datetime.datetime(self.yr, self.mth, self.dy, 7, 30, 0).timetuple()

        self.assertTrue(_compareResults(self.cal.parse('730',  start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('0730', start), (target, 2)))

        target = datetime.datetime(self.yr, self.mth, self.dy, 17, 30, 0).timetuple()

        self.assertTrue(_compareResults(self.cal.parse('1730',   start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('173000', start), (target, 2)))

    def testDates(self):
        start  = datetime.datetime(self.yr, self.mth, self.dy, self.hr, self.mn, self.sec).timetuple()
        target = datetime.datetime(2006, 8, 25,  self.hr, self.mn, self.sec).timetuple()

        self.assertTrue(_compareResults(self.cal.parse('08/25/2006',      start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('08.25.2006',      start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('8/25/06',         start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('August 25, 2006', start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('Aug 25, 2006',    start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('Aug. 25, 2006',   start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('August 25 2006',  start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('Aug 25 2006',     start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('Aug. 25 2006',    start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('25 August 2006',  start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('25 Aug 2006',     start), (target, 1)))

        if self.mth > 8 or (self.mth == 8 and self.dy > 25):
            target = datetime.datetime(self.yr + 1, 8, 25,  self.hr, self.mn, self.sec).timetuple()
        else:
            target = datetime.datetime(self.yr, 8, 25,  self.hr, self.mn, self.sec).timetuple()

        self.assertTrue(_compareResults(self.cal.parse('8/25',      start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('8.25',      start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('08/25',     start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('August 25', start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('Aug 25',    start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('Aug. 25',   start), (target, 1)))

        # added test to ensure 4-digit year is recognized in the absence of day
        target = datetime.datetime(2013, 8, 1,  self.hr, self.mn, self.sec).timetuple()
        self.assertTrue(_compareResults(self.cal.parse('Aug. 2013',   start), (target, 1)))

    def testLeapDays(self):
        start  = datetime.datetime(self.yr, self.mth, self.dy, self.hr, self.mn, self.sec).timetuple()
        target = datetime.datetime(2000, 2, 29,  self.hr, self.mn, self.sec).timetuple()

        self.assertTrue(_compareResults(self.cal.parse('02/29/2000', start), (target, 1)))

        target = datetime.datetime(2004, 2, 29,  self.hr, self.mn, self.sec).timetuple()

        self.assertTrue(_compareResults(self.cal.parse('02/29/2004', start), (target, 1)))

        target = datetime.datetime(2008, 2, 29,  self.hr, self.mn, self.sec).timetuple()

        self.assertTrue(_compareResults(self.cal.parse('02/29/2008', start), (target, 1)))

        target = datetime.datetime(2012, 2, 29,  self.hr, self.mn, self.sec).timetuple()

        self.assertTrue(_compareResults(self.cal.parse('02/29/2012', start), (target, 1)))

        dNormal = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
        dLeap   = (31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)

        for i in range(1,12):
            self.assertTrue(self.cal.ptc.daysInMonth(i, 1999), dNormal[i - 1])
            self.assertTrue(self.cal.ptc.daysInMonth(i, 2000), dLeap[i - 1])
            self.assertTrue(self.cal.ptc.daysInMonth(i, 2001), dNormal[i - 1])
            self.assertTrue(self.cal.ptc.daysInMonth(i, 2002), dNormal[i - 1])
            self.assertTrue(self.cal.ptc.daysInMonth(i, 2003), dNormal[i - 1])
            self.assertTrue(self.cal.ptc.daysInMonth(i, 2004), dLeap[i - 1])
            self.assertTrue(self.cal.ptc.daysInMonth(i, 2005), dNormal[i - 1])

    def testDaySuffixes(self):
        start  = datetime.datetime(self.yr, self.mth, self.dy, self.hr, self.mn, self.sec).timetuple()
        target = datetime.datetime(2008, 8, 22,  self.hr, self.mn, self.sec).timetuple()

        self.assertTrue(_compareResults(self.cal.parse('August 22nd, 2008', start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('Aug 22nd, 2008',    start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('Aug. 22nd, 2008',   start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('August 22nd 2008',  start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('Aug 22nd 2008',     start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('Aug. 22nd 2008',    start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('22nd August 2008',  start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('22nd Aug 2008',     start), (target, 1)))

        target = datetime.datetime(1949, 12, 31,  self.hr, self.mn, self.sec).timetuple()

        self.assertTrue(_compareResults(self.cal.parse('December 31st, 1949', start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('Dec 31st, 1949',      start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('December 31st 1949',  start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('Dec 31st 1949',       start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('31st December 1949',  start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('31st Dec 1949',       start), (target, 1)))

        target = datetime.datetime(2008, 8, 23,  self.hr, self.mn, self.sec).timetuple()

        self.assertTrue(_compareResults(self.cal.parse('August 23rd, 2008', start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('Aug 23rd, 2008',    start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('Aug. 23rd, 2008',   start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('August 23rd 2008',  start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('Aug 23rd 2008',     start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('Aug. 23rd 2008',    start), (target, 1)))

        target = datetime.datetime(2008, 8, 25,  self.hr, self.mn, self.sec).timetuple()

        self.assertTrue(_compareResults(self.cal.parse('August 25th, 2008', start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('Aug 25th, 2008',    start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('Aug. 25th, 2008',   start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('August 25th 2008',  start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('Aug 25th 2008',     start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('Aug. 25th 2008',    start), (target, 1)))

    def testSpecialTimes(self):
        start  = datetime.datetime(self.yr, self.mth, self.dy, self.hr, self.mn, self.sec).timetuple()
        target = datetime.datetime(self.yr, self.mth, self.dy, 6, 0, 0).timetuple()

        self.assertTrue(_compareResults(self.cal.parse('morning', start), (target, 2)))

        target = datetime.datetime(self.yr, self.mth, self.dy, 8, 0, 0).timetuple()

        self.assertTrue(_compareResults(self.cal.parse('breakfast', start), (target, 2)))

        target = datetime.datetime(self.yr, self.mth, self.dy, 12, 0, 0).timetuple()

        self.assertTrue(_compareResults(self.cal.parse('lunch', start), (target, 2)))

        target = datetime.datetime(self.yr, self.mth, self.dy, 18, 0, 0).timetuple()

        self.assertTrue(_compareResults(self.cal.parse('evening', start), (target, 2)))

        target = datetime.datetime(self.yr, self.mth, self.dy, 19,0, 0).timetuple()

        self.assertTrue(_compareResults(self.cal.parse('dinner', start), (target, 2)))

        target = datetime.datetime(self.yr, self.mth, self.dy, 21, 0, 0).timetuple()

        self.assertTrue(_compareResults(self.cal.parse('night',   start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('tonight', start), (target, 2)))

    def testMidnight(self):
        start  = datetime.datetime(self.yr, self.mth, self.dy, self.hr, self.mn, self.sec).timetuple()
        target = datetime.datetime(self.yr, self.mth, self.dy, 0, 0, 0).timetuple()

        self.assertTrue(_compareResults(self.cal.parse('midnight',      start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('12:00:00 AM',   start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('12:00 AM',      start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('12 AM',         start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('12AM',          start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('12am',          start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('12a',           start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('0000',          start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('00:00',         start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('12:00:00 A.M.', start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('12:00 A.M.',    start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('12 A.M.',       start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('12A.M.',        start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('12a.m.',        start), (target, 2)))

    def testNoon(self):
        start  = datetime.datetime(self.yr, self.mth, self.dy, self.hr, self.mn, self.sec).timetuple()
        target = datetime.datetime(self.yr, self.mth, self.dy, 12, 0, 0).timetuple()

        self.assertTrue(_compareResults(self.cal.parse('noon',          start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('12:00:00 PM',   start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('12:00 PM',      start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('12 PM',         start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('12PM',          start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('12pm',          start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('12p',           start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('1200',          start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('12:00',         start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('12:00:00 P.M.', start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('12:00 P.M.',    start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('12 P.M.',       start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('12P.M.',        start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('12p.m.',        start), (target, 2)))


    def testDaysOfWeek(self):
        start =  datetime.datetime(2014, 10, 25, self.hr, self.mn, self.sec).timetuple()

        target = datetime.datetime(2014, 10, 26, self.hr, self.mn, self.sec).timetuple()
        self.assertTrue(_compareResults(self.cal.parse('sunday',          start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('sun',          start), (target, 1)))

        target = datetime.datetime(2014, 10, 27, self.hr, self.mn, self.sec).timetuple()
        self.assertTrue(_compareResults(self.cal.parse('Monday',          start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('mon',          start), (target, 1)))

        target = datetime.datetime(2014, 10, 28, self.hr, self.mn, self.sec).timetuple()
        self.assertTrue(_compareResults(self.cal.parse('tuesday',          start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('tues',          start), (target, 1)))

        target = datetime.datetime(2014, 10, 29, self.hr, self.mn, self.sec).timetuple()
        self.assertTrue(_compareResults(self.cal.parse('wednesday',          start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('wed',          start), (target, 1)))

        target = datetime.datetime(2014, 10, 30, self.hr, self.mn, self.sec).timetuple()
        self.assertTrue(_compareResults(self.cal.parse('thursday',          start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('thu',          start), (target, 1)))

        target = datetime.datetime(2014, 10, 31, self.hr, self.mn, self.sec).timetuple()
        self.assertTrue(_compareResults(self.cal.parse('friday',          start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('fri',          start), (target, 1)))

        target = datetime.datetime(2014, 11, 1, self.hr, self.mn, self.sec).timetuple()
        self.assertTrue(_compareResults(self.cal.parse('saturday',          start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('sat',          start), (target, 1)))


    # def testMonths(self):
    #
    #     start  = datetime.datetime(self.yr, self.mth, self.dy, self.hr, self.mn, self.sec).timetuple()
    #
    #     target = datetime.datetime(self.yr, self.mth, self.dy, 12, 0, 0).timetuple()
    #
    #     self.assertTrue(_compareResults(self.cal.parse('jun',        start), (target, 2)))
    #     self.assertTrue(_compareResults(self.cal.parse('12:00:00 PM', start), (target, 2)))
    #     self.assertTrue(_compareResults(self.cal.parse('12:00 PM',    start), (target, 2)))
    #     self.assertTrue(_compareResults(self.cal.parse('12 PM',       start), (target, 2)))
    #     self.assertTrue(_compareResults(self.cal.parse('12PM',        start), (target, 2)))
    #     self.assertTrue(_compareResults(self.cal.parse('12pm',        start), (target, 2)))
    #     self.assertTrue(_compareResults(self.cal.parse('12p',         start), (target, 2)))
    #     self.assertTrue(_compareResults(self.cal.parse('1200',        start), (target, 2)))
    #     self.assertTrue(_compareResults(self.cal.parse('12:00',       start), (target, 2)))

if __name__ == "__main__":
    unittest.main()
