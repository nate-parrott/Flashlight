
"""
Test parsing of complex date and times
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

    def testDates(self):
        start  = datetime.datetime(self.yr, self.mth, self.dy, self.hr, self.mn, self.sec).timetuple()
        target = datetime.datetime(2006, 8, 25,  17, 0, 0).timetuple()

        self.assertTrue(_compareResults(self.cal.parse('08/25/2006 5pm',        start), (target, 3)))
        self.assertTrue(_compareResults(self.cal.parse('5pm on 08.25.2006',     start), (target, 3)))
        self.assertTrue(_compareResults(self.cal.parse('5pm August 25, 2006',   start), (target, 3)))
        self.assertTrue(_compareResults(self.cal.parse('5pm August 25th, 2006', start), (target, 3)))
        self.assertTrue(_compareResults(self.cal.parse('5pm 25 August, 2006',   start), (target, 3)))
        self.assertTrue(_compareResults(self.cal.parse('5pm 25th August, 2006', start), (target, 3)))
        self.assertTrue(_compareResults(self.cal.parse('Aug 25, 2006 5pm',      start), (target, 3)))
        self.assertTrue(_compareResults(self.cal.parse('Aug 25th, 2006 5pm',    start), (target, 3)))
        self.assertTrue(_compareResults(self.cal.parse('25 Aug, 2006 5pm',      start), (target, 3)))
        self.assertTrue(_compareResults(self.cal.parse('25th Aug 2006, 5pm',    start), (target, 3)))

        if self.mth > 8 or (self.mth == 8 and self.dy > 5):
            target = datetime.datetime(self.yr + 1, 8, 5, 17, 0, 0).timetuple()
        else:
            target = datetime.datetime(self.yr, 8, 5, 17, 0, 0).timetuple()

        self.assertTrue(_compareResults(self.cal.parse('8/5 at 5pm',     start), (target, 3)))
        self.assertTrue(_compareResults(self.cal.parse('5pm 8.5',        start), (target, 3)))
        self.assertTrue(_compareResults(self.cal.parse('08/05 5pm',      start), (target, 3)))
        self.assertTrue(_compareResults(self.cal.parse('August 5 5pm',   start), (target, 3)))
        self.assertTrue(_compareResults(self.cal.parse('5pm Aug 05',     start), (target, 3)))
        self.assertTrue(_compareResults(self.cal.parse('Aug 05 5pm',     start), (target, 3)))
        self.assertTrue(_compareResults(self.cal.parse('Aug 05th 5pm',   start), (target, 3)))
        self.assertTrue(_compareResults(self.cal.parse('5 August 5pm',   start), (target, 3)))
        self.assertTrue(_compareResults(self.cal.parse('5th August 5pm', start), (target, 3)))
        self.assertTrue(_compareResults(self.cal.parse('5pm 05 Aug',     start), (target, 3)))
        self.assertTrue(_compareResults(self.cal.parse('05 Aug 5pm',     start), (target, 3)))
        self.assertTrue(_compareResults(self.cal.parse('05th Aug 5pm',   start), (target, 3)))

        self.assertTrue(_compareResults(self.cal.parse('August 5th 5pm', start), (target, 3)))

        if self.mth > 8 or (self.mth == 8 and self.dy > 5):
            target = datetime.datetime(self.yr + 1, 8, 5, 12, 0, 0).timetuple()
        else:
            target = datetime.datetime(self.yr, 8, 5, 12, 0, 0).timetuple()

        self.assertTrue(_compareResults(self.cal.parse('August 5th 12pm',  start), (target, 3)))
        self.assertTrue(_compareResults(self.cal.parse('August 5th 12:00', start), (target, 3)))



if __name__ == "__main__":
    unittest.main()
