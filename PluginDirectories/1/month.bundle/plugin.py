from __future__ import print_function
import sys, calendar, six
from datetime import datetime as dt


def get_date(month):
    year = dt.now().year if dt.strptime(month, '%B').month >= dt.now().month else dt.now().year + 1
    s_date = '{month} {year}'.format(month=month, year=year)
    first = dt.strptime(s_date, "%B %Y")
    return (s_date, first)

def monthly_calendar(date):
    cal = calendar.HTMLCalendar(calendar.SUNDAY)
    month = cal.formatmonth(date.year, date.month)
    return (date.strftime('%B %d, %Y'), month)

def extract_date(fields, test=False):
    # we may have a 'month/X' parameter or not
    month, year, month_fmt = None, None, ''
    if test: print(fields)
    for k,v in fields.iteritems():
        if k.startswith('month/'):
            month = v
    if '~year' in fields:
        # year could be an actual year or '2020 calendar' for May 2020 calendar
        parts = [int(s) for s in fields['~year'].split() if s.isdigit()]
        if len(parts) > 0:
            year = parts[0]

    if '~month' in fields:
        # can be a month, 'Jun', or a month-year, 'Jun 2020'
        parts = fields['~month'].split()
        for p in parts:
            if p.isdigit():
                year = int(p)
                parts.remove(p)
        if len(parts) == 0:
            # no month?
            month = dt.now().strftime('%b')
        else:
            month = parts[0]
    
    if month is not None:
        month_fmt = '%b' if len(month) == 3 else '%B'
        try:
            month = dt.strptime(month, month_fmt).month
        except ValueError:
            month = dt.now().month
    else:
        month = dt.now().month

    if year is None:
        year = dt.now().year if month >= dt.now().month else dt.now().year + 1

    if test: print('year=%s (%s), month=%s (%s)' % (year, year.__class__, month, month.__class__))
    return dt(year, month, 1)
        

def results(fields, original_query):
    try:
        date = extract_date(fields)
    except:
        date = dt.now()
    string_cal, html_cal = monthly_calendar(date)
    html = open("calendar.html").read().decode('utf-8').replace("<!-- MONTH -->", html_cal)
    return {
        "title": "Calendar for '{0}'".format(string_cal),
        "run_args": [date.strftime('%Y-%m-%d')],
        "html": html
    }

def run(date_string):
    print(date_string, file=sys.stderr)
    date = dt.strptime(date_string, '%Y-%m-%d')
    script = """
tell application "Calendar"
	switch view to month view
	view calendar at date ("{month} 1, {year}")
end tell
""".format(month=date.strftime('%B'), year=date.year)
    # import syslog
    # syslog.openlog('Python')
    # syslog.syslog(syslog.LOG_ALERT, script)
    # syslog.syslog(syslog.LOG_ALERT, "osascript -e '%s'" % script)
    # _, month_cal = monthly_calendar(date)
    # print("osascript -e '%s'." % script, file=sys.stderr)
    import os
    os.system("osascript -e '%s'" % script)
    

import unittest
class TestPlugin(unittest.TestCase):
    YEAR = dt.now().year
    YEAR_NEXT = dt.now().year+1
    MONTH = dt.now().month
    INPUTS = (
            # calendar for June 2020
            # month June 2020
            # month of June 2020
            ({'~month': 'June 2020'}, '2020-06-01'),
            # June
            # calendar for June
            # month June 
            # month of June 
            ({'~month': 'June'}, '{0}-06-01'.format(YEAR if MONTH <= 6 else YEAR_NEXT)),
            # May calendar
            ({'~year': 'calendar', 'month/May': 'May'}, '{0}-05-01'.format(YEAR if MONTH <= 5 else YEAR_NEXT)),
            # May 2020 calendar
            ({'~year': '2020 calendar', 'month/May': 'May'}, '2020-05-01'),
            # April 2020
            ({'~year': '2020', 'month/April': 'April'}, '2020-04-01'),
            # Partial
            ({'~month': 'Jan 2020'}, '2020-01-01'), # month:Jan 2020
            ({'~month': 'Feb 2020'}, '2020-02-01'), # month:Feb 2020
            ({'~month': 'Mar 2020'}, '2020-03-01'), # month:Mar 2020
            ({'~month': 'Apr 2020'}, '2020-04-01'), # month:Apr 2020
            ({'~month': 'May 2020'}, '2020-05-01'), # month:May 2020
            ({'~month': 'Jun 2020'}, '2020-06-01'), # month:Jun 2020
            ({'~month': 'Jul 2020'}, '2020-07-01'), # month:Jul 2020
            ({'~month': 'Aug 2020'}, '2020-08-01'), # month:Aug 2020
            ({'~month': 'Sep 2020'}, '2020-09-01'), # month:Sep 2020
            ({'~month': 'Oct 2020'}, '2020-10-01'), # month:Oct 2020
            ({'~month': 'Nov 2020'}, '2020-11-01'), # month:Nov 2020
            ({'~month': 'Dec 2020'}, '2020-12-01'), # month:Dec 2020
            # TODO: invalid dates
            ({}, '{0}-{1:02d}-01'.format(YEAR, MONTH))
            )
    def test_date_parsing(self):
        for params, date in TestPlugin.INPUTS:
            expected = dt.strptime(date, '%Y-%m-%d')
            actual = extract_date(params, test=True)
            self.assertEqual(actual, expected, msg='Expected %s to be %s, but was %s.' % (params, date, actual))

    def test_results(self):
        for params, date in TestPlugin.INPUTS:
            print(params, date)
            res = results(params, 'calendar for ')
            self.assertEqual(len(res), 3)
            run_args = res['run_args']
            self.assertEqual(len(run_args), 1)
            self.assertEqual(run_args[0], date, msg='Expected %s to be %s for %s.' % (run_args[0], date, params))

    
if (__name__ == '__main__'):
    unittest.main()
    # ret = results({"~month": "July"}, "month of July")
    # print(ret['html'])
