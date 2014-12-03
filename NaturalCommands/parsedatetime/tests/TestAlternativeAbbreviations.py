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

class pdtLocale_en(pdt.pdt_locales.pdtLocale_icu):
    """Update en locale to include a bunch of different abbreviations"""
    def __init__(self):
        super(pdtLocale_en, self).__init__(localeID='en_us')
        self.Weekdays      = [ 'monday', 'tuesday', 'wednesday',
                               'thursday', 'friday', 'saturday', 'sunday',
                             ]
        self.shortWeekdays = [ 'mon|mond', 'tue|tues', 'wed|wedn',
                               'thu|thur|thurs', 'fri|frid', 'sat|sa', 'sun|su',
                             ]
        self.Months        = [ 'january', 'february', 'march',
                               'april',   'may',      'june',
                               'july',    'august',   'september',
                               'october', 'november', 'december',
                             ]
        self.shortMonths   = [ 'jan|janu', 'feb|febr', 'mar|marc',
                               'apr|apri', 'may', 'jun|june',
                               'jul', 'aug|augu', 'sep|sept',
                               'oct|octo', 'nov|novem', 'dec|decem',
                             ]

class test(unittest.TestCase):

    def setUp(self):
        pdt.pdtLocales['en_us'] = pdtLocale_en # override for the test
        self.ptc = pdt.Constants('en_us', usePyICU=False)
        self.cal = pdt.Calendar(self.ptc)
        self.yr, self.mth, self.dy, self.hr, self.mn, self.sec, self.wd, self.yd, self.isdst = time.localtime()


    def testDaysOfWeek(self):
        start =  datetime.datetime(2014, 10, 25, self.hr, self.mn, self.sec).timetuple()

        target = datetime.datetime(2014, 10, 26, self.hr, self.mn, self.sec).timetuple()
        self.assertTrue(_compareResults(self.cal.parse('sunday',          start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('sun',          start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('su',          start), (target, 1)))

        target = datetime.datetime(2014, 10, 27, self.hr, self.mn, self.sec).timetuple()
        self.assertTrue(_compareResults(self.cal.parse('Monday',          start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('mon',          start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('mond',          start), (target, 1)))

        target = datetime.datetime(2014, 10, 28, self.hr, self.mn, self.sec).timetuple()
        self.assertTrue(_compareResults(self.cal.parse('tuesday',          start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('tues',          start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('tue',          start), (target, 1)))

        target = datetime.datetime(2014, 10, 29, self.hr, self.mn, self.sec).timetuple()
        self.assertTrue(_compareResults(self.cal.parse('wednesday',          start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('wedn',          start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('wed',          start), (target, 1)))

        target = datetime.datetime(2014, 10, 30, self.hr, self.mn, self.sec).timetuple()
        self.assertTrue(_compareResults(self.cal.parse('thursday',          start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('thu',          start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('thur',          start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('thurs',          start), (target, 1)))

        target = datetime.datetime(2014, 10, 31, self.hr, self.mn, self.sec).timetuple()
        self.assertTrue(_compareResults(self.cal.parse('friday',          start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('fri',          start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('frid',          start), (target, 1)))

        target = datetime.datetime(2014, 11, 1, self.hr, self.mn, self.sec).timetuple()
        self.assertTrue(_compareResults(self.cal.parse('saturday',          start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('sat',          start), (target, 1)))
        self.assertTrue(_compareResults(self.cal.parse('sa',          start), (target, 1)))

    def testMonths(self):
        start =  datetime.datetime(2014,1, 1, self.hr, self.mn, self.sec).timetuple()
        for dates, expected_date in [
                  ('jan|janu|january', datetime.datetime(2014, 1, 1, self.hr, self.mn, self.sec).timetuple() ),
                  ('feb|febr|february', datetime.datetime(2014, 2, 1, self.hr, self.mn, self.sec).timetuple() ),
                  ('mar|marc|march', datetime.datetime(2014, 3, 1, self.hr, self.mn, self.sec).timetuple() ),
                  ('apr|apri|april', datetime.datetime(2014, 4, 1, self.hr, self.mn, self.sec).timetuple() ),
                  ('may|may', datetime.datetime(2014, 5, 1, self.hr, self.mn, self.sec).timetuple() ),
                  ('jun|june', datetime.datetime(2014, 6, 1, self.hr, self.mn, self.sec).timetuple() ),
                  ('jul|july', datetime.datetime(2014, 7, 1, self.hr, self.mn, self.sec).timetuple() ),
                  ('aug|augu|august', datetime.datetime(2014, 8, 1, self.hr, self.mn, self.sec).timetuple() ),
                  ('sep|sept|september', datetime.datetime(2014, 9, 1, self.hr, self.mn, self.sec).timetuple() ),
                  ('oct|octo|october', datetime.datetime(2014, 10, 1, self.hr, self.mn, self.sec).timetuple() ),
                  ('nov|novem|november', datetime.datetime(2014, 11, 1, self.hr, self.mn, self.sec).timetuple() ),
                  ('dec|decem|december', datetime.datetime(2014, 12, 1, self.hr, self.mn, self.sec).timetuple() )
                             ]:
                for dateText in dates.split("|"):
                    print dateText
                    self.assertTrue(_compareResults(self.cal.parse(dateText,          start), (expected_date, 1)))

