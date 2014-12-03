
"""
Test parsing of simple date and times using the French locale

Note: requires PyICU
"""
from __future__ import unicode_literals
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
        self.ptc = pdt.Constants('fr_FR', usePyICU=True)
        self.cal = pdt.Calendar(self.ptc)

        self.yr, self.mth, self.dy, self.hr, self.mn, self.sec, self.wd, self.yd, self.isdst = time.localtime()

    def testTimes(self):
        if self.ptc.localeID == 'fr_FR':
            start  = datetime.datetime(self.yr, self.mth, self.dy, self.hr, self.mn, self.sec).timetuple()
            target = datetime.datetime(self.yr, self.mth, self.dy, 23, 0, 0).timetuple()

            self.assertTrue(_compareResults(self.cal.parse('2300',  start), (target, 2)))
            self.assertTrue(_compareResults(self.cal.parse('23:00', start), (target, 2)))

            target = datetime.datetime(self.yr, self.mth, self.dy, 11, 0, 0).timetuple()

            self.assertTrue(_compareResults(self.cal.parse('1100',  start), (target, 2)))
            self.assertTrue(_compareResults(self.cal.parse('11:00', start), (target, 2)))

            target = datetime.datetime(self.yr, self.mth, self.dy, 7, 30, 0).timetuple()

            self.assertTrue(_compareResults(self.cal.parse('730',  start), (target, 2)))
            self.assertTrue(_compareResults(self.cal.parse('0730', start), (target, 2)))

            target = datetime.datetime(self.yr, self.mth, self.dy, 17, 30, 0).timetuple()

            self.assertTrue(_compareResults(self.cal.parse('1730',   start), (target, 2)))
            self.assertTrue(_compareResults(self.cal.parse('173000', start), (target, 2)))

    def testDates(self):
        if self.ptc.localeID == 'fr_FR':
            start  = datetime.datetime(self.yr, self.mth, self.dy, self.hr, self.mn, self.sec).timetuple()
            target = datetime.datetime(2006, 8, 25, self.hr, self.mn, self.sec).timetuple()

            self.assertTrue(_compareResults(self.cal.parse('25/08/2006',       start), (target, 1)))
            self.assertTrue(_compareResults(self.cal.parse('25/8/06',          start), (target, 1)))
            self.assertTrue(_compareResults(self.cal.parse('ao\xfbt 25, 2006', start), (target, 1)))
            self.assertTrue(_compareResults(self.cal.parse('ao\xfbt 25 2006',  start), (target, 1)))

            if self.mth > 8 or (self.mth == 8 and self.dy > 25):
                target = datetime.datetime(self.yr+1, 8, 25, self.hr, self.mn, self.sec).timetuple()
            else:
                target = datetime.datetime(self.yr, 8, 25,  self.hr, self.mn, self.sec).timetuple()

            self.assertTrue(_compareResults(self.cal.parse('25/8',  start), (target, 1)))
            self.assertTrue(_compareResults(self.cal.parse('25/08', start), (target, 1)))

    def testWeekDays(self):
        if self.ptc.localeID == 'fr_FR':
            start  = datetime.datetime(self.yr, self.mth, self.dy, self.hr, self.mn, self.sec).timetuple()

            o1 = self.ptc.CurrentDOWParseStyle
            o2 = self.ptc.DOWParseStyle

              # set it up so the current dow returns current day
            self.ptc.CurrentDOWParseStyle = True
            self.ptc.DOWParseStyle        = 1

            for i in range(0,7):
                dow = self.ptc.shortWeekdays[i]

                result = self.cal.parse(dow, start)

                yr, mth, dy, hr, mn, sec, wd, yd, isdst = result[0]

                self.assertTrue(wd == i)

            self.ptc.CurrentDOWParseStyle = o1
            self.ptc.DOWParseStyle        = o2

class pdtLocale_fr(pdt.pdt_locales.pdtLocale_icu):
    """French locale with french today/tomorrow/yesterday"""
    def __init__(self):
        super(pdtLocale_fr, self).__init__(localeID='fr_FR')
        self.dayOffsets.update({"aujourd'hui": 0, 'demain': 1, 'hier': -1})

class TestDayOffsets(test):
    # test how Aujourd'hui/Demain/Hier are parsed
    def setUp(self):
        super(TestDayOffsets, self).setUp()
        self.__old_pdtlocale_fr = pdt.pdtLocales.get('fr_FR') # save for later
        pdt.pdtLocales['fr_FR'] = pdtLocale_fr # override for the test
        self.ptc = pdt.Constants('fr_FR', usePyICU=False)
        self.cal = pdt.Calendar(self.ptc)

    def test_dayoffsets(self):
        start  = datetime.datetime(self.yr, self.mth, self.dy, 9)
        for date_string, expected_day_offset in [
                ("Aujourd'hui", 0),
                ("aujourd'hui", 0),
                ("Demain", 1),
                ("demain", 1),
                ("Hier", -1),
                ("hier", -1),
                ("today", 0), # assume default names exist
                ("tomorrow", 1),
                ("yesterday", -1),
                ("au jour de hui", None)]:
            got_dt, rc = self.cal.parseDT(date_string, start)
            if expected_day_offset is not None:
                self.assertEqual(rc, 1)
                target = (start + datetime.timedelta(days=expected_day_offset))
                self.assertEqual(got_dt, target)
            else:
                self.assertEqual(rc, 0)

    def tearDown(self):
        if self.__old_pdtlocale_fr is not None: # restore the locale
            pdt.pdtLocales['fr_FR'] = self.__old_pdtlocale_fr
        super(TestDayOffsets, self).tearDown()


if __name__ == "__main__":
    unittest.main()
