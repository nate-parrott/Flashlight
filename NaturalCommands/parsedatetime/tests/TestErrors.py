
"""
Test parsing of units
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


def _compareResultsErrorFlag(result, check):
    target, t_flag = result
    value,  v_flag = check

    t_yr, t_mth, t_dy, _, _, _, _, _, _ = target
    v_yr, v_mth, v_dy, _, _, _, _, _, _ = value

    return (t_flag == v_flag)


class test(unittest.TestCase):

    def setUp(self):
        self.cal = pdt.Calendar()
        self.yr, self.mth, self.dy, self.hr, self.mn, self.sec, self.wd, self.yd, self.isdst = time.localtime()

    def testErrors(self):
        s     = datetime.datetime.now()
        start = s.timetuple()

        # These tests all return current date/time as they are out of range
        self.assertTrue(_compareResults(self.cal.parse('01/0',   start), (start, 0)))
        self.assertTrue(_compareResults(self.cal.parse('08/35',  start), (start, 0)))
        self.assertTrue(_compareResults(self.cal.parse('18/35',  start), (start, 0)))
        self.assertTrue(_compareResults(self.cal.parse('1799',   start), (start, 0)))
        self.assertTrue(_compareResults(self.cal.parse('781',    start), (start, 0)))
        self.assertTrue(_compareResults(self.cal.parse('2702',   start), (start, 0)))
        self.assertTrue(_compareResults(self.cal.parse('78',     start), (start, 0)))
        self.assertTrue(_compareResults(self.cal.parse('11',     start), (start, 0)))
        self.assertTrue(_compareResults(self.cal.parse('1',      start), (start, 0)))
        self.assertTrue(_compareResults(self.cal.parse('174565', start), (start, 0)))
        self.assertTrue(_compareResults(self.cal.parse('177505', start), (start, 0)))
        # ensure short month names do not cause false positives within a word - jun (june)
        self.assertTrue(_compareResults(self.cal.parse('injunction', start), (start, 0)))
        # ensure short month names do not cause false positives at the start of a word - jul (juuly)
        self.assertTrue(_compareResults(self.cal.parse('julius', start), (start, 0)))
        # ensure short month names do not cause false positives at the end of a word - mar (march)
        self.assertTrue(_compareResults(self.cal.parse('lamar', start), (start, 0)))
        # ensure short weekday names do not cause false positives within a word - mon (monday)
        self.assertTrue(_compareResults(self.cal.parse('demonize', start), (start, 0)))
        # ensure short weekday names do not cause false positives at the start of a word - mon (monday)
        self.assertTrue(_compareResults(self.cal.parse('money', start), (start, 0)))
        # ensure short weekday names do not cause false positives at the end of a word - th (thursday)
        self.assertTrue(_compareResults(self.cal.parse('month', start), (start, 0)))

        # This test actually parses into *something* for some locales, so need to check the error flag
        self.assertTrue(_compareResultsErrorFlag(self.cal.parse('30/030/01/071/07', start), (start, 1)))


if __name__ == "__main__":
    unittest.main()
