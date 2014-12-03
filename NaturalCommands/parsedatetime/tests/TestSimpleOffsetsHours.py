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

    def testHoursFromNow(self):
        s = datetime.datetime.now()
        t = s + datetime.timedelta(hours=5)

        start  = s.timetuple()
        target = t.timetuple()

        self.assertTrue(_compareResults(self.cal.parse('5 hours from now', start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('5 hour from now',  start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('5 hr from now',    start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('in 5 hours',       start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('in 5 hour',        start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('5 hours',          start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('5 hr',             start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('5h',               start), (target, 2)))

        self.assertTrue(_compareResults(self.cal.parse('five hours from now', start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('five hour from now',  start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('five hr from now',    start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('in five hours',       start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('in five hour',        start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('five hours',          start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('five hr',             start), (target, 2)))

    def testHoursBeforeNow(self):
        s = datetime.datetime.now()
        t = s + datetime.timedelta(hours=-5)

        start  = s.timetuple()
        target = t.timetuple()

        self.assertTrue(_compareResults(self.cal.parse('5 hours before now', start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('5 hr before now',    start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('5h before now',      start), (target, 2)))

        self.assertTrue(_compareResults(self.cal.parse('five hours before now', start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('five hr before now',    start), (target, 2)))


if __name__ == "__main__":
    unittest.main()
