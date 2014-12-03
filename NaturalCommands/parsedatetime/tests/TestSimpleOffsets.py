
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

    def testNow(self):
        s = datetime.datetime.now()

        start = s.timetuple()
        target = s.timetuple()

        self.assertTrue(_compareResults(self.cal.parse('now', start), (target, 2)))

    def testMinutesFromNow(self):
        s = datetime.datetime.now()
        t = s + datetime.timedelta(minutes=5)

        start  = s.timetuple()
        target = t.timetuple()

        self.assertTrue(_compareResults(self.cal.parse('5 minutes from now', start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('5 min from now',     start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('5m from now',        start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('in 5 minutes',       start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('in 5 min',           start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('5 minutes',          start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('5 min',              start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('5m',                 start), (target, 2)))

        self.assertTrue(_compareResults(self.cal.parse('five minutes from now', start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('five min from now',     start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('in five minutes',       start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('in five min',           start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('five minutes',          start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('five min',              start), (target, 2)))

    def testMinutesBeforeNow(self):
        s = datetime.datetime.now()
        t = s + datetime.timedelta(minutes=-5)

        start  = s.timetuple()
        target = t.timetuple()

        self.assertTrue(_compareResults(self.cal.parse('5 minutes before now', start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('5 min before now',     start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('5m before now',        start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('5 minutes ago',        start), (target, 2)))

        self.assertTrue(_compareResults(self.cal.parse('five minutes before now', start), (target, 2)))
        self.assertTrue(_compareResults(self.cal.parse('five min before now',     start), (target, 2)))

    def testWeekFromNow(self):
        s = datetime.datetime.now()
        t = s + datetime.timedelta(weeks=1)

        start  = s.timetuple()
        target = t.timetuple()

        self.assertTrue(_compareResults(self.cal.parse('in 1 week',           start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('1 week from now',     start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('in one week',         start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('one week from now',   start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('in 7 days',           start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('7 days from now',     start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('in seven days',       start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('seven days from now', start), (target, 1)))
        #self.assertTrue(_compareResults(self.cal.parse('next week',           start), (target, 1)))

    def testWeekBeforeNow(self):
        s = datetime.datetime.now()
        t = s + datetime.timedelta(weeks=-1)

        start  = s.timetuple()
        target = t.timetuple()

        self.assertTrue(_compareResults(self.cal.parse('1 week before now',     start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('one week before now',   start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('7 days before now',     start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('seven days before now', start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('1 week ago',            start), (target, 1)))
        #self.assertTrue(_compareResults(self.cal.parse('last week',              tart), (target, 1)))

    def testSpecials(self):
        s = datetime.datetime.now()
        t = datetime.datetime(self.yr, self.mth, self.dy, 9, 0, 0) + datetime.timedelta(days=1)

        start  = s.timetuple()
        target = t.timetuple()

        self.assertTrue(_compareResults(self.cal.parse('tomorrow', start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('next day', start), (target, 1)))

        t      = datetime.datetime(self.yr, self.mth, self.dy, 9, 0, 0) + datetime.timedelta(days=-1)
        target = t.timetuple()

        self.assertTrue(_compareResults(self.cal.parse('yesterday', start), (target, 1)))

        t      = datetime.datetime(self.yr, self.mth, self.dy, 9, 0, 0)
        target = t.timetuple()

        self.assertTrue(_compareResults(self.cal.parse('today', start), (target, 1)))


if __name__ == "__main__":
    unittest.main()
