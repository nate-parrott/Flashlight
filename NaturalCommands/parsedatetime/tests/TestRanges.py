
"""
Test parsing of simple date and times
"""

import unittest, time, datetime
import parsedatetime as pdt


  # a special compare function is used to allow us to ignore the seconds as
  # the running of the test could cross a minute boundary
def _compareResults(result, check):
    targetStart, targetEnd, t_flag = result
    valueStart, valueEnd,  v_flag = check

    t1_yr, t1_mth, t1_dy, t1_hr, t1_min, _, _, _, _ = targetStart
    v1_yr, v1_mth, v1_dy, v1_hr, v1_min, _, _, _, _ = valueStart

    t2_yr, t2_mth, t2_dy, t2_hr, t2_min, _, _, _, _ = targetEnd
    v2_yr, v2_mth, v2_dy, v2_hr, v2_min, _, _, _, _ = valueEnd

    return ((t1_yr == v1_yr) and (t1_mth == v1_mth) and (t1_dy == v1_dy) and (t1_hr == v1_hr) and
            (t1_min == v1_min) and (t2_yr == v2_yr) and (t2_mth == v2_mth) and (t2_dy == v2_dy) and
            (t2_hr == v2_hr) and (t2_min == v2_min) and (t_flag == v_flag))


class test(unittest.TestCase):

    def setUp(self):
        self.cal = pdt.Calendar()
        self.yr, self.mth, self.dy, self.hr, self.mn, self.sec, self.wd, self.yd, self.isdst = time.localtime()

    def testTimes(self):
        start = datetime.datetime(self.yr, self.mth, self.dy, self.hr, self.mn, self.sec).timetuple()

        targetStart = datetime.datetime(self.yr, self.mth, self.dy, 14, 0, 0).timetuple()
        targetEnd   = datetime.datetime(self.yr, self.mth, self.dy, 17, 30, 0).timetuple()

        self.assertTrue(_compareResults(self.cal.evalRanges("2 pm - 5:30 pm",          start), (targetStart, targetEnd, 2)))
        self.assertTrue(_compareResults(self.cal.evalRanges("2pm - 5:30pm",            start), (targetStart, targetEnd, 2)))
        self.assertTrue(_compareResults(self.cal.evalRanges("2:00:00 pm - 5:30:00 pm", start), (targetStart, targetEnd, 2)))
        self.assertTrue(_compareResults(self.cal.evalRanges("2 - 5:30pm",              start), (targetStart, targetEnd, 2)))
        self.assertTrue(_compareResults(self.cal.evalRanges("14:00 - 17:30",           start), (targetStart, targetEnd, 2)))

        targetStart = datetime.datetime(self.yr, self.mth, self.dy, 10, 0, 0).timetuple()
        targetEnd   = datetime.datetime(self.yr, self.mth, self.dy, 13, 30, 0).timetuple()

        self.assertTrue(_compareResults(self.cal.evalRanges("10AM - 1:30PM",            start), (targetStart, targetEnd, 2)))
        self.assertTrue(_compareResults(self.cal.evalRanges("10:00:00 am - 1:30:00 pm", start), (targetStart, targetEnd, 2)))
        self.assertTrue(_compareResults(self.cal.evalRanges("10:00 - 13:30",            start), (targetStart, targetEnd, 2)))

        targetStart = datetime.datetime(self.yr, self.mth, self.dy, 15, 30, 0).timetuple()
        targetEnd   = datetime.datetime(self.yr, self.mth, self.dy, 17, 0, 0).timetuple()

        self.assertTrue(_compareResults(self.cal.evalRanges("today 3:30-5PM", start), (targetStart, targetEnd, 2)))

    def testDates(self):
        start = datetime.datetime(self.yr, self.mth, self.dy, self.hr, self.mn, self.sec).timetuple()

        targetStart = datetime.datetime(2006, 8, 29, self.hr, self.mn, self.sec).timetuple()
        targetEnd   = datetime.datetime(2006, 9, 2,self.hr, self.mn, self.sec).timetuple()

        self.assertTrue(_compareResults(self.cal.evalRanges("August 29, 2006 - September 2, 2006", start), (targetStart, targetEnd, 1)))
        self.assertTrue(_compareResults(self.cal.evalRanges("August 29 - September 2, 2006",       start), (targetStart, targetEnd, 1)))

        targetStart = datetime.datetime(2006, 8, 29, self.hr, self.mn, self.sec).timetuple()
        targetEnd   = datetime.datetime(2006, 9, 2, self.hr, self.mn, self.sec).timetuple()

        self.assertTrue(_compareResults(self.cal.evalRanges("08/29/06 - 09/02/06", start), (targetStart, targetEnd, 1)))


    #def testSubRanges(self):
    #    start = datetime.datetime(self.yr, self.mth, self.dy, self.hr, self.mn, self.sec).timetuple()

    #    targetStart = datetime.datetime(2006, 8, 1, 9, 0, 0).timetuple()
    #    targetEnd   = datetime.datetime(2006, 8, 15, 9, 0, 0).timetuple()

    #    self.assertTrue(_compareResults(self.cal.evalRanges("August 1-15, 2006", start), (targetStart, targetEnd, 1)))


if __name__ == "__main__":
    unittest.main()

