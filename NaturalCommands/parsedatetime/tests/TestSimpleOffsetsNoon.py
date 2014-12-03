
"""
Test parsing of 'simple' offsets
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

    def testOffsetAfterNoon(self):
        s = datetime.datetime(self.yr, self.mth, self.dy, 10, 0, 0)
        t = datetime.datetime(self.yr, self.mth, self.dy, 12, 0, 0) + datetime.timedelta(hours=5)

        start  = s.timetuple()
        target = t.timetuple()

        self.assertTrue(_compareResults(self.cal.parse('5 hours after 12pm',     start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('five hours after 12pm',  start), (target, 2)))
        #self.assertTrue(_compareResults(self.cal.parse('5 hours after 12 pm',    start), (target, 2)))
        #self.assertTrue(_compareResults(self.cal.parse('5 hours after 12:00pm',  start), (target, 2)))
        #self.assertTrue(_compareResults(self.cal.parse('5 hours after 12:00 pm', start), (target, 2)))
        #self.assertTrue(_compareResults(self.cal.parse('5 hours after noon',     start), (target, 2)))
        #self.assertTrue(_compareResults(self.cal.parse('5 hours from noon',      start), (target, 2)))

    def testOffsetBeforeNoon(self):
        s = datetime.datetime.now()
        t = datetime.datetime(self.yr, self.mth, self.dy, 12, 0, 0) + datetime.timedelta(hours=-5)

        start  = s.timetuple()
        target = t.timetuple()

        #self.assertTrue(_compareResults(self.cal.parse('5 hours before noon',     start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('5 hours before 12pm',     start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('five hours before 12pm',  start), (target, 2)))
        #self.assertTrue(_compareResults(self.cal.parse('5 hours before 12 pm',    start), (target, 2)))
        #self.assertTrue(_compareResults(self.cal.parse('5 hours before 12:00pm',  start), (target, 2)))
        #self.assertTrue(_compareResults(self.cal.parse('5 hours before 12:00 pm', start), (target, 2)))


if __name__ == "__main__":
    unittest.main()
