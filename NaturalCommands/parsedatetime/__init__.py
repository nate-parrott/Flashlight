#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# vim: sw=2 ts=2 sts=2
#
# Copyright 2004-2014 Mike Taylor
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""parsedatetime

Parse human-readable date/time text.

Requires Python 2.6 or later
"""

__author__       = 'Mike Taylor (bear@bear.im)'
__copyright__    = 'Copyright (c) 2004 Mike Taylor'
__license__      = 'Apache v2.0'
__version__      = '1.5'
__contributors__ = [ 'Darshana Chhajed',
                     'Michael Lim (lim.ck.michael@gmail.com)',
                     'Bernd Zeimetz (bzed@debian.org)',
                   ]

import re
import time
import datetime
import calendar
import email.utils

try:
    from itertools import imap
except ImportError:
    imap = map

from . import pdt_locales

# as a library, do *not* setup logging
# see http://docs.python.org/2/howto/logging.html#configuring-logging-for-a-library
# Set default logging handler to avoid "No handler found" warnings.
import logging

try:  # Python 2.7+
    from logging import NullHandler
except ImportError:
    class NullHandler(logging.Handler):
        def emit(self, record):
            pass

log = logging.getLogger(__name__)
log.addHandler(NullHandler())

pdtLocales = { 'icu':   pdt_locales.pdtLocale_icu,
               'en_US': pdt_locales.pdtLocale_en,
               'en_AU': pdt_locales.pdtLocale_au,
               'es_ES': pdt_locales.pdtLocale_es,
               'de_DE': pdt_locales.pdtLocale_de,
               'nl_NL': pdt_locales.pdtLocale_nl,
             }


# Copied from feedparser.py
# Universal Feedparser
# Copyright (c) 2002-2006, Mark Pilgrim, All rights reserved.
# Originally a def inside of _parse_date_w3dtf()
def _extract_date(m):
    year = int(m.group('year'))
    if year < 100:
        year = 100 * int(time.gmtime()[0] / 100) + int(year)
    if year < 1000:
        return 0, 0, 0
    julian = m.group('julian')
    if julian:
        julian = int(julian)
        month = julian / 30 + 1
        day = julian % 30 + 1
        jday = None
        while jday != julian:
            t = time.mktime((year, month, day, 0, 0, 0, 0, 0, 0))
            jday = time.gmtime(t)[-2]
            diff = abs(jday - julian)
            if jday > julian:
                if diff < day:
                    day = day - diff
                else:
                    month = month - 1
                    day = 31
            elif jday < julian:
                if day + diff < 28:
                    day = day + diff
                else:
                    month = month + 1
        return year, month, day
    month = m.group('month')
    day = 1
    if month is None:
        month = 1
    else:
        month = int(month)
        day = m.group('day')
        if day:
            day = int(day)
        else:
            day = 1
    return year, month, day

# Copied from feedparser.py
# Universal Feedparser
# Copyright (c) 2002-2006, Mark Pilgrim, All rights reserved.
# Originally a def inside of _parse_date_w3dtf()
def _extract_time(m):
    if not m:
        return 0, 0, 0
    hours = m.group('hours')
    if not hours:
        return 0, 0, 0
    hours = int(hours)
    minutes = int(m.group('minutes'))
    seconds = m.group('seconds')
    if seconds:
        seconds = int(seconds)
    else:
        seconds = 0
    return hours, minutes, seconds


# Copied from feedparser.py
# Universal Feedparser
# Copyright (c) 2002-2006, Mark Pilgrim, All rights reserved.
# Modified to return a tuple instead of mktime
#
# Original comment:
#   W3DTF-style date parsing adapted from PyXML xml.utils.iso8601, written by
#   Drake and licensed under the Python license.  Removed all range checking
#   for month, day, hour, minute, and second, since mktime will normalize
#   these later
def _parse_date_w3dtf(dateString):
    # the __extract_date and __extract_time methods were
    # copied-out so they could be used by my code --bear
    def __extract_tzd(m):
        '''Return the Time Zone Designator as an offset in seconds from UTC.'''
        if not m:
            return 0
        tzd = m.group('tzd')
        if not tzd:
            return 0
        if tzd == 'Z':
            return 0
        hours = int(m.group('tzdhours'))
        minutes = m.group('tzdminutes')
        if minutes:
            minutes = int(minutes)
        else:
            minutes = 0
        offset = (hours*60 + minutes) * 60
        if tzd[0] == '+':
            return -offset
        return offset

    __date_re = (r'(?P<year>\d\d\d\d)'
                 r'(?:(?P<dsep>-|)'
                 r'(?:(?P<julian>\d\d\d)'
                 r'|(?P<month>\d\d)(?:(?P=dsep)(?P<day>\d\d))?))?')
    __tzd_re = r'(?P<tzd>[-+](?P<tzdhours>\d\d)(?::?(?P<tzdminutes>\d\d))|Z)'
    __tzd_rx = re.compile(__tzd_re)
    __time_re = (r'(?P<hours>\d\d)(?P<tsep>:|)(?P<minutes>\d\d)'
                 r'(?:(?P=tsep)(?P<seconds>\d\d(?:[.,]\d+)?))?'
                 + __tzd_re)
    __datetime_re = '%s(?:T%s)?' % (__date_re, __time_re)
    __datetime_rx = re.compile(__datetime_re)
    m = __datetime_rx.match(dateString)
    if (m is None) or (m.group() != dateString): return
    return _extract_date(m) + _extract_time(m) + (0, 0, 0)


_monthnames = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul',
               'aug', 'sep', 'oct', 'nov', 'dec',
               'january', 'february', 'march', 'april', 'may', 'june', 'july',
               'august', 'september', 'october', 'november', 'december']
_daynames = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']

# Copied from feedparser.py
# Universal Feedparser
# Copyright (c) 2002-2006, Mark Pilgrim, All rights reserved.
# Modified to return a tuple instead of mktime
#
def _parse_date_rfc822(dateString):
    '''Parse an RFC822, RFC1123, RFC2822, or asctime-style date'''
    data = dateString.split()
    if data[0][-1] in (',', '.') or data[0].lower() in _daynames:
        del data[0]
    if len(data) == 4:
        s = data[3]
        i = s.find('+')
        if i > 0:
            data[3:] = [s[:i], s[i+1:]]
        else:
            data.append('')
        dateString = " ".join(data)
    if len(data) < 5:
        dateString += ' 00:00:00 GMT'
    return email.utils.parsedate_tz(dateString)

# # rfc822.py defines several time zones, but we define some extra ones.
# # 'ET' is equivalent to 'EST', etc.
# _additional_timezones = {'AT': -400, 'ET': -500,
#                          'CT': -600, 'MT': -700,
#                          'PT': -800}
# email.utils._timezones.update(_additional_timezones)


class Calendar:
    """
    A collection of routines to input, parse and manipulate date and times.
    The text can either be 'normal' date values or it can be human readable.
    """

    def __init__(self, constants=None):
        """
        Default constructor for the L{Calendar} class.

        @type  constants: object
        @param constants: Instance of the class L{Constants}

        @rtype:  object
        @return: L{Calendar} instance
        """
          # if a constants reference is not included, use default
        if constants is None:
            self.ptc = Constants()
        else:
            self.ptc = constants

        self.weekdyFlag    = False  # monday/tuesday/...
        self.dateStdFlag   = False  # 07/21/06
        self.dateStrFlag   = False  # July 21st, 2006
        self.timeStdFlag   = False  # 5:50
        self.meridianFlag  = False  # am/pm
        self.dayStrFlag    = False  # tomorrow/yesterday/today/..
        self.timeStrFlag   = False  # lunch/noon/breakfast/...
        self.modifierFlag  = False  # after/before/prev/next/..
        self.modifier2Flag = False  # after/before/prev/next/..
        self.unitsFlag     = False  # hrs/weeks/yrs/min/..
        self.qunitsFlag    = False  # h/m/t/d..

        self.timeFlag      = 0
        self.dateFlag      = 0

    def _convertUnitAsWords(self, unitText):
        """
        Converts text units into their number value.

        @type  unitText: string
        @param unitText: number text to convert

        @rtype:  integer
        @return: numerical value of unitText
        """
        word_list, a, b = re.split(r"[,\s-]+", unitText), 0, 0
        for word in word_list:
            x = self.ptc.small.get(word)
            if x is not None:
                a += x
            elif word == "hundred":
                a *= 100
            else:
                x = self.ptc.magnitude.get(word)
                if x is not None:
                    b += a * x
                    a = 0
                elif word in self.ptc.ignore:
                    pass
                else:
                    raise Exception("Unknown number: " + word)
        return a + b

    def _buildTime(self, source, quantity, modifier, units):
        """
        Take C{quantity}, C{modifier} and C{unit} strings and convert them into values.
        After converting, calcuate the time and return the adjusted sourceTime.

        @type  source:   time
        @param source:   time to use as the base (or source)
        @type  quantity: string
        @param quantity: quantity string
        @type  modifier: string
        @param modifier: how quantity and units modify the source time
        @type  units:    string
        @param units:    unit of the quantity (i.e. hours, days, months, etc)

        @rtype:  struct_time
        @return: C{struct_time} of the calculated time
        """
        log.debug('_buildTime: [%s][%s][%s]' % (quantity, modifier, units))

        if source is None:
            source = time.localtime()

        if quantity is None:
            quantity = ''
        else:
            quantity = quantity.strip()

        qty = self._quantityToInt(quantity)

        if modifier in self.ptc.Modifiers:
            qty = qty * self.ptc.Modifiers[modifier]

            if units is None or units == '':
                units = 'dy'

        # plurals are handled by regex's (could be a bug tho)

        (yr, mth, dy, hr, mn, sec, _, _, _) = source

        start    = datetime.datetime(yr, mth, dy, hr, mn, sec)
        target   = start
        #realunit = next((key for key, values in self.ptc.units.items() if any(imap(units.__contains__, values))), None)
        realunit = units
        for key, values in self.ptc.units.items():
            if units in values:
                realunit = key
                break

        log.debug('units %s --> realunit %s' % (units, realunit))

        if realunit == 'years':
            target        = self.inc(start, year=qty)
            self.dateFlag = 1
        elif realunit == 'months':
            target        = self.inc(start, month=qty)
            self.dateFlag = 1
        else:
            if realunit == 'days':
                target        = start + datetime.timedelta(days=qty)
                self.dateFlag = 1
            elif realunit == 'hours':
                target        = start + datetime.timedelta(hours=qty)
                self.timeFlag = 2
            elif realunit == 'minutes':
                target        = start + datetime.timedelta(minutes=qty)
                self.timeFlag = 2
            elif realunit == 'seconds':
                target        = start + datetime.timedelta(seconds=qty)
                self.timeFlag = 2
            elif realunit == 'weeks':
                target        = start + datetime.timedelta(weeks=qty)
                self.dateFlag = 1

        return target.timetuple()

    def parseDate(self, dateString, sourceTime=None):
        """
        Parse short-form date strings::

            '05/28/2006' or '04.21'

        @type  dateString: string
        @param dateString: text to convert to a C{datetime}

        @rtype:  struct_time
        @return: calculated C{struct_time} value of dateString
        """
        if sourceTime is None:
            yr, mth, dy, hr, mn, sec, wd, yd, isdst = time.localtime()
        else:
            yr, mth, dy, hr, mn, sec, wd, yd, isdst = sourceTime

        # values pulled from regex's will be stored here and later
        # assigned to mth, dy, yr based on information from the locale
        # -1 is used as the marker value because we want zero values
        # to be passed thru so they can be flagged as errors later
        v1 = -1
        v2 = -1
        v3 = -1

        s = dateString
        m = self.ptc.CRE_DATE2.search(s)
        if m is not None:
            index = m.start()
            v1    = int(s[:index])
            s     = s[index + 1:]

        m = self.ptc.CRE_DATE2.search(s)
        if m is not None:
            index = m.start()
            v2    = int(s[:index])
            v3    = int(s[index + 1:])
        else:
            v2 = int(s.strip())

        v = [ v1, v2, v3 ]
        d = { 'm': mth, 'd': dy, 'y': yr }

        for i in range(0, 3):
            n = v[i]
            c = self.ptc.dp_order[i]
            if n >= 0:
                d[c] = n

        # if the year is not specified and the date has already
        # passed, increment the year
        if v3 == -1 and ((mth > d['m']) or (mth == d['m'] and dy > d['d'])):
            yr = d['y'] + 1
        else:
            yr  = d['y']

        mth = d['m']
        dy  = d['d']

        # birthday epoch constraint
        if yr < self.ptc.BirthdayEpoch:
            yr += 2000
        elif yr < 100:
            yr += 1900

        log.debug('parseDate: %s %s %s %s' % (yr, mth, dy, self.ptc.daysInMonth(mth, yr)))

        if (mth > 0 and mth <= 12) and \
           (dy > 0 and dy <= self.ptc.daysInMonth(mth, yr)):
            sourceTime = (yr, mth, dy, hr, mn, sec, wd, yd, isdst)
        else:
            self.dateFlag = 0
            self.timeFlag = 0
            sourceTime    = time.localtime() # return current time if date
                                             # string is invalid

        return sourceTime

    def parseDateText(self, dateString, sourceTime=None):
        """
        Parse long-form date strings::

            'May 31st, 2006'
            'Jan 1st'
            'July 2006'

        @type  dateString: string
        @param dateString: text to convert to a datetime

        @rtype:  struct_time
        @return: calculated C{struct_time} value of dateString
        """
        if sourceTime is None:
            yr, mth, dy, hr, mn, sec, wd, yd, isdst = time.localtime()
        else:
            yr, mth, dy, hr, mn, sec, wd, yd, isdst = sourceTime

        currentMth = mth
        currentDy  = dy

        log.debug('parseDateText currentMth %s currentDy %s' % (mth, dy))

        s   = dateString.lower()
        m   = self.ptc.CRE_DATE3.search(s)
        mth = m.group('mthname')
        mth = self.ptc.MonthOffsets[mth]

        if m.group('day') !=  None:
            dy = int(m.group('day'))
        else:
            dy = 1

        if m.group('year') !=  None:
            yr = int(m.group('year'))

            # birthday epoch constraint
            if yr < self.ptc.BirthdayEpoch:
                yr += 2000
            elif yr < 100:
                yr += 1900

        elif (mth < currentMth) or (mth == currentMth and dy < currentDy):
            # if that day and month have already passed in this year,
            # then increment the year by 1
            yr += self.ptc.YearParseStyle

        if dy > 0 and dy <= self.ptc.daysInMonth(mth, yr):
            sourceTime = (yr, mth, dy, hr, mn, sec, wd, yd, isdst)
        else:
            # Return current time if date string is invalid
            self.dateFlag = 0
            self.timeFlag = 0
            sourceTime    = time.localtime()

        log.debug('parseDateText returned dateFlag %d timeFlag %d mth %d dy %d yr %d sourceTime %s' %
                    (self.dateFlag, self.timeFlag, mth, dy, yr, sourceTime))

        return sourceTime

    def evalRanges(self, datetimeString, sourceTime=None):
        """
        Evaluate the C{datetimeString} text and determine if
        it represents a date or time range.

        @type  datetimeString: string
        @param datetimeString: datetime text to evaluate
        @type  sourceTime:     struct_time
        @param sourceTime:     C{struct_time} value to use as the base

        @rtype:  tuple
        @return: tuple of: start datetime, end datetime and the invalid flag
        """
        startTime = ''
        endTime   = ''
        startDate = ''
        endDate   = ''
        rangeFlag = 0

        s = datetimeString.strip().lower()

        if self.ptc.rangeSep in s:
            s = s.replace(self.ptc.rangeSep, ' %s ' % self.ptc.rangeSep)
            s = s.replace('  ', ' ')

        m = self.ptc.CRE_TIMERNG1.search(s)
        if m is not None:
            rangeFlag = 1
        else:
            m = self.ptc.CRE_TIMERNG2.search(s)
            if m is not None:
                rangeFlag = 2
            else:
                m = self.ptc.CRE_TIMERNG4.search(s)
                if m is not None:
                    rangeFlag = 7
                else:
                    m = self.ptc.CRE_TIMERNG3.search(s)
                    if m is not None:
                        rangeFlag = 3
                    else:
                        m = self.ptc.CRE_DATERNG1.search(s)
                        if m is not None:
                            rangeFlag = 4
                        else:
                            m = self.ptc.CRE_DATERNG2.search(s)
                            if m is not None:
                                rangeFlag = 5
                            else:
                                m = self.ptc.CRE_DATERNG3.search(s)
                                if m is not None:
                                    rangeFlag = 6

        log.debug('evalRanges: rangeFlag = %s [%s]' % (rangeFlag, s))

        if m is not None:
            if (m.group() != s):
                # capture remaining string
                parseStr = m.group()
                chunk1   = s[:m.start()]
                chunk2   = s[m.end():]
                s        = '%s %s' % (chunk1, chunk2)
                flag     = 1

                sourceTime, flag = self.parse(s, sourceTime)

                if flag == 0:
                    sourceTime = None
            else:
                parseStr = s

        if rangeFlag == 1:
            m                = re.search(self.ptc.rangeSep, parseStr)
            startTime, sflag = self.parse((parseStr[:m.start()]),       sourceTime)
            endTime, eflag   = self.parse((parseStr[(m.start() + 1):]), sourceTime)

            if (eflag != 0)  and (sflag != 0):
                return (startTime, endTime, 2)

        elif rangeFlag == 2:
            m                = re.search(self.ptc.rangeSep, parseStr)
            startTime, sflag = self.parse((parseStr[:m.start()]),       sourceTime)
            endTime, eflag   = self.parse((parseStr[(m.start() + 1):]), sourceTime)

            if (eflag != 0)  and (sflag != 0):
                return (startTime, endTime, 2)

        elif rangeFlag == 3 or rangeFlag == 7:
            m = re.search(self.ptc.rangeSep, parseStr)
            # capturing the meridian from the end time
            if self.ptc.usesMeridian:
                ampm = re.search(self.ptc.am[0], parseStr)

                # appending the meridian to the start time
                if ampm is not None:
                    startTime, sflag = self.parse((parseStr[:m.start()] + self.ptc.meridian[0]), sourceTime)
                else:
                    startTime, sflag = self.parse((parseStr[:m.start()] + self.ptc.meridian[1]), sourceTime)
            else:
                startTime, sflag = self.parse((parseStr[:m.start()]), sourceTime)

            endTime, eflag = self.parse(parseStr[(m.start() + 1):], sourceTime)

            if (eflag != 0)  and (sflag != 0):
                return (startTime, endTime, 2)

        elif rangeFlag == 4:
            m                = re.search(self.ptc.rangeSep, parseStr)
            startDate, sflag = self.parse((parseStr[:m.start()]),       sourceTime)
            endDate, eflag   = self.parse((parseStr[(m.start() + 1):]), sourceTime)

            if (eflag != 0)  and (sflag != 0):
                return (startDate, endDate, 1)

        elif rangeFlag == 5:
            m       = re.search(self.ptc.rangeSep, parseStr)
            endDate = parseStr[(m.start() + 1):]

            # capturing the year from the end date
            date    = self.ptc.CRE_DATE3.search(endDate)
            endYear = date.group('year')

            # appending the year to the start date if the start date
            # does not have year information and the end date does.
            # eg : "Aug 21 - Sep 4, 2007"
            if endYear is not None:
                startDate = (parseStr[:m.start()]).strip()
                date      = self.ptc.CRE_DATE3.search(startDate)
                startYear = date.group('year')

                if startYear is None:
                    startDate = startDate + ', ' + endYear
            else:
                startDate = parseStr[:m.start()]

            startDate, sflag = self.parse(startDate, sourceTime)
            endDate, eflag   = self.parse(endDate, sourceTime)

            if (eflag != 0)  and (sflag != 0):
                return (startDate, endDate, 1)

        elif rangeFlag == 6:
            m = re.search(self.ptc.rangeSep, parseStr)

            startDate = parseStr[:m.start()]

            # capturing the month from the start date
            mth = self.ptc.CRE_DATE3.search(startDate)
            mth = mth.group('mthname')

            # appending the month name to the end date
            endDate = mth + parseStr[(m.start() + 1):]

            startDate, sflag = self.parse(startDate, sourceTime)
            endDate, eflag   = self.parse(endDate, sourceTime)

            if (eflag != 0)  and (sflag != 0):
                return (startDate, endDate, 1)
        else:
            # if range is not found
            sourceTime = time.localtime()

            return (sourceTime, sourceTime, 0)

    def _CalculateDOWDelta(self, wd, wkdy, offset, style, currentDayStyle):
        """
        Based on the C{style} and C{currentDayStyle} determine what
        day-of-week value is to be returned.

        @type  wd:              integer
        @param wd:              day-of-week value for the current day
        @type  wkdy:            integer
        @param wkdy:            day-of-week value for the parsed day
        @type  offset:          integer
        @param offset:          offset direction for any modifiers (-1, 0, 1)
        @type  style:           integer
        @param style:           normally the value set in C{Constants.DOWParseStyle}
        @type  currentDayStyle: integer
        @param currentDayStyle: normally the value set in C{Constants.CurrentDOWParseStyle}

        @rtype:  integer
        @return: calculated day-of-week
        """
        if offset == 1:
            # modifier is indicating future week eg: "next".
            # DOW is calculated as DOW of next week
            diff = 7 - wd + wkdy

        elif offset == -1:
            # modifier is indicating past week eg: "last","previous"
            # DOW is calculated as DOW of previous week
            diff = wkdy - wd - 7

        elif offset == 0:
            # modifier is indiacting current week eg: "this"
            # DOW is calculated as DOW of this week
            diff = wkdy - wd

        elif offset == 2:
            # no modifier is present.
            # i.e. string to be parsed is just DOW
            if style == 1:
                # next occurance of the DOW is calculated
                if currentDayStyle == True:
                    if wkdy >= wd:
                        diff = wkdy - wd
                    else:
                        diff = 7 - wd + wkdy
                else:
                    if wkdy > wd:
                        diff = wkdy - wd
                    else:
                        diff = 7 - wd + wkdy

            elif style == -1:
                # last occurance of the DOW is calculated
                if currentDayStyle == True:
                    if wkdy <= wd:
                        diff = wkdy - wd
                    else:
                        diff = wkdy - wd - 7
                else:
                    if wkdy < wd:
                        diff = wkdy - wd
                    else:
                        diff = wkdy - wd - 7
            else:
                # occurance of the DOW in the current week is calculated
                diff = wkdy - wd

        log.debug("wd %s, wkdy %s, offset %d, style %d" % (wd, wkdy, offset, style))

        return diff

    def _quantityToInt(self, quantity):
        """
        Convert a quantity, either spelled-out or numeric, to an integer

        @type    quantity: string
        @param   quantity: quantity to parse to int
        @rtype:  int
        @return: the quantity as an integer, defaulting to 0
        """
        if(len(quantity) == 0):
           return 1

        try:
           return int(quantity)
        except ValueError:
           pass

        try:
           return self.ptc.numbers[quantity]
        except KeyError:
           pass

        return 0

    def _evalModifier(self, modifier, chunk1, chunk2, sourceTime):
        """
        Evaluate the C{modifier} string and following text (passed in
        as C{chunk1} and C{chunk2}) and if they match any known modifiers
        calculate the delta and apply it to C{sourceTime}.

        @type  modifier:   string
        @param modifier:   modifier text to apply to sourceTime
        @type  chunk1:     string
        @param chunk1:     first text chunk that followed modifier (if any)
        @type  chunk2:     string
        @param chunk2:     second text chunk that followed modifier (if any)
        @type  sourceTime: struct_time
        @param sourceTime: C{struct_time} value to use as the base

        @rtype:  tuple
        @return: tuple of: remaining text and the modified sourceTime
        """

        offset = self.ptc.Modifiers[modifier]

        if sourceTime is not None:
            (yr, mth, dy, hr, mn, sec, wd, yd, isdst) = sourceTime
        else:
            (yr, mth, dy, hr, mn, sec, wd, yd, isdst) = time.localtime()

        # capture the units after the modifier and the remaining
        # string after the unit
        m = self.ptc.CRE_REMAINING.search(chunk2)
        if m is not None:
            index  = m.start() + 1
            unit   = chunk2[:m.start()]
            chunk2 = chunk2[index:]
        else:
            unit   = chunk2
            chunk2 = ''

        flag = False

        log.debug("modifier [%s] chunk1 [%s] chunk2 [%s] unit [%s] flag %s" % (modifier, chunk1, chunk2, unit, flag))

        if unit == 'month' or \
           unit == 'mth' or \
           unit == 'm':
            if offset == 0:
                dy         = self.ptc.daysInMonth(mth, yr)
                sourceTime = (yr, mth, dy, 9, 0, 0, wd, yd, isdst)
            elif offset == 2:
                # if day is the last day of the month, calculate the last day
                # of the next month
                if dy == self.ptc.daysInMonth(mth, yr):
                    dy = self.ptc.daysInMonth(mth + 1, yr)

                start      = datetime.datetime(yr, mth, dy, 9, 0, 0)
                target     = self.inc(start, month=1)
                sourceTime = target.timetuple()
            else:
                start      = datetime.datetime(yr, mth, 1, 9, 0, 0)
                target     = self.inc(start, month=offset)
                sourceTime = target.timetuple()

            flag = True
            self.dateFlag = 1

        if unit == 'week' or \
             unit == 'wk' or \
             unit == 'w':
            if offset == 0:
                start      = datetime.datetime(yr, mth, dy, 17, 0, 0)
                target     = start + datetime.timedelta(days=(4 - wd))
                sourceTime = target.timetuple()
            elif offset == 2:
                start      = datetime.datetime(yr, mth, dy, 9, 0, 0)
                target     = start + datetime.timedelta(days=7)
                sourceTime = target.timetuple()
            else:
                return self._evalModifier(modifier, chunk1, "monday " + chunk2, sourceTime)

            flag          = True
            self.dateFlag = 1

        if unit == 'day' or \
            unit == 'dy' or \
            unit == 'd':
            if offset == 0:
                sourceTime    = (yr, mth, dy, 17, 0, 0, wd, yd, isdst)
                self.timeFlag = 2
            elif offset == 2:
                start      = datetime.datetime(yr, mth, dy, hr, mn, sec)
                target     = start + datetime.timedelta(days=1)
                sourceTime = target.timetuple()
            else:
                start      = datetime.datetime(yr, mth, dy, 9, 0, 0)
                target     = start + datetime.timedelta(days=offset)
                sourceTime = target.timetuple()

            flag          = True
            self.dateFlag = 1

        if unit == 'hour' or \
           unit == 'hr':
            if offset == 0:
                sourceTime = (yr, mth, dy, hr, 0, 0, wd, yd, isdst)
            else:
                start      = datetime.datetime(yr, mth, dy, hr, 0, 0)
                target     = start + datetime.timedelta(hours=offset)
                sourceTime = target.timetuple()

            flag          = True
            self.timeFlag = 2

        if unit == 'year' or \
             unit == 'yr' or \
             unit == 'y':
            if offset == 0:
                sourceTime = (yr, 12, 31, hr, mn, sec, wd, yd, isdst)
            elif offset == 2:
                sourceTime = (yr + 1, mth, dy, hr, mn, sec, wd, yd, isdst)
            else:
                sourceTime = (yr + offset, 1, 1, 9, 0, 0, wd, yd, isdst)

            flag          = True
            self.dateFlag = 1

        if not flag:
            if modifier == 'eom':
                self.modifierFlag = False
                dy                = self.ptc.daysInMonth(mth, yr)
                sourceTime        = (yr, mth, dy, 9, 0, 0, wd, yd, isdst)
                self.dateFlag     = 2
                flag              = True
            elif modifier == 'eoy':
                self.modifierFlag = False
                mth               = 12
                dy                = self.ptc.daysInMonth(mth, yr)
                sourceTime        = (yr, mth, dy, 9, 0, 0, wd, yd, isdst)
                self.dateFlag     = 2
                flag              = True

        if not flag:
            m = self.ptc.CRE_WEEKDAY.match(unit)
            if m is not None:
                log.debug('CRE_WEEKDAY matched')
                wkdy          = m.group()
                self.dateFlag = 1

                if modifier == 'eod':
                    # Calculate the  upcoming weekday
                    self.modifierFlag = False
                    (sourceTime, _)   = self.parse(wkdy, sourceTime)
                    sources           = self.ptc.buildSources(sourceTime)
                    self.timeFlag     = 2

                    if modifier in sources:
                        sourceTime = sources[modifier]
                else:
                    wkdy       = self.ptc.WeekdayOffsets[wkdy]
                    diff       = self._CalculateDOWDelta(wd, wkdy, offset,
                                                         self.ptc.DOWParseStyle,
                                                         self.ptc.CurrentDOWParseStyle)
                    start      = datetime.datetime(yr, mth, dy, 9, 0, 0)
                    target     = start + datetime.timedelta(days=diff)
                    sourceTime = target.timetuple()

                flag          = True
                self.dateFlag = 1

        if not flag:
            m = self.ptc.CRE_TIME.match(unit)
            if m is not None or unit in self.ptc.re_values['now']:
                log.debug('CRE_TIME matched')
                self.modifierFlag = False
                (yr, mth, dy, hr, mn, sec, wd, yd, isdst), _ = self.parse(unit)

                start      = datetime.datetime(yr, mth, dy, hr, mn, sec)
                target     = start + datetime.timedelta(days=offset)
                sourceTime = target.timetuple()
                flag       = True
            else:
                self.modifierFlag = False

                log.debug('check for modifications to source time')

                # check if the remaining text is parsable and if so,
                # use it as the base time for the modifier source time
                t, flag2 = self.parse('%s %s' % (chunk1, unit), sourceTime)

                log.debug('flag2 = %s t = %s' % (flag2, t))

                if flag2 != 0:
                    sourceTime = t

                sources = self.ptc.buildSources(sourceTime)

                log.debug('looking for %s in %s' % (modifier, sources))

                if modifier in sources:
                    log.debug('modifier found in sources')
                    sourceTime    = sources[modifier]
                    flag          = True
                    self.timeFlag = 2

        # if the word after next is a number, the string is more than likely
        # to be "next 4 hrs" which we will have to combine the units with the
        # rest of the string
        if not flag:
            if offset < 0:
                # if offset is negative, the unit has to be made negative
                unit = '-%s' % unit

            chunk2 = '%s %s' % (unit, chunk2)

        self.modifierFlag = False

        log.debug('returning chunk = "%s" and sourceTime = %s' % (chunk2, sourceTime))

        #return '%s %s' % (chunk1, chunk2), sourceTime
        return '%s' % chunk2, sourceTime

    def _evalModifier2(self, modifier, chunk1 , chunk2, sourceTime):
        """
        Evaluate the C{modifier} string and following text (passed in
        as C{chunk1} and C{chunk2}) and if they match any known modifiers
        calculate the delta and apply it to C{sourceTime}.

        @type  modifier:   string
        @param modifier:   modifier text to apply to C{sourceTime}
        @type  chunk1:     string
        @param chunk1:     first text chunk that followed modifier (if any)
        @type  chunk2:     string
        @param chunk2:     second text chunk that followed modifier (if any)
        @type  sourceTime: struct_time
        @param sourceTime: C{struct_time} value to use as the base

        @rtype:  tuple
        @return: tuple of: remaining text and the modified sourceTime
        """

        offset = self.ptc.Modifiers[modifier]

        self.modifier2Flag = False
        log.debug("modifier2 [%s] chunk1 [%s] chunk2 [%s] sourceTime %s" % (modifier, chunk1, chunk2, sourceTime))

        # If the string after the negative modifier starts with digits,
        # then it is likely that the string is similar to ' before 3 days'
        # or 'evening prior to 3 days'.
        # In this case, the total time is calculated by subtracting '3 days'
        # from the current date.
        # So, we have to identify the quantity and negate it before parsing
        # the string.
        # This is not required for strings not starting with digits since the
        # string is enough to calculate the sourceTime
        if chunk2 != '':

            currDOWParseStyle = self.ptc.DOWParseStyle
            if offset < 0:
                m = self.ptc.CRE_NUMBER.match(chunk2.strip())
                if m is not None:
                    qty    = self._quantityToInt(m.group()) * -1
                    chunk2 = chunk2[m.end():]
                    chunk2 = '%d%s' % (qty, chunk2)
                else:
                    # enforce selection of the previous period
                    # driven by DOWParseStyle and CurrentDOWParseStyle
                    # FIXME: this is not threadsafe!
                    self.ptc.DOWParseStyle = -1

            sourceTime, flag1 = self.parse(chunk2, sourceTime)
            # restore DOWParseStyle setting
            self.DOWParseStyle = currDOWParseStyle
            if flag1 == 0:
                flag1 = True
            else:
                flag1 = False
            flag2 = False
        else:
            flag1 = False

        if chunk1 != '':
            if offset < 0:
                m = self.ptc.CRE_NUMBER.search(chunk1.strip())
                if m is not None:
                    qty    = self._quantityToInt(m.group()) * -1
                    chunk1 = chunk1[m.end():]
                    chunk1 = '%d%s' % (qty, chunk1)

            tempDateFlag       = self.dateFlag
            tempTimeFlag       = self.timeFlag
            sourceTime2, flag2 = self.parse(chunk1, sourceTime)
        else:
            return sourceTime, (flag1 and flag2)

        # if chunk1 is not a datetime and chunk2 is then do not use datetime
        # value returned by parsing chunk1
        if not (flag1 == False and flag2 == 0):
            sourceTime = sourceTime2
        else:
            self.timeFlag = tempTimeFlag
            self.dateFlag = tempDateFlag

        return sourceTime, (flag1 and flag2)

    def _evalString(self, datetimeString, sourceTime=None):
        """
        Calculate the datetime based on flags set by the L{parse()} routine

        Examples handled::
            RFC822, W3CDTF formatted dates
            HH:MM[:SS][ am/pm]
            MM/DD/YYYY
            DD MMMM YYYY

        @type  datetimeString: string
        @param datetimeString: text to try and parse as more "traditional"
                               date/time text
        @type  sourceTime:     struct_time
        @param sourceTime:     C{struct_time} value to use as the base

        @rtype:  datetime
        @return: calculated C{struct_time} value or current C{struct_time}
                 if not parsed
        """
        s   = datetimeString.strip()
        now = sourceTime or time.localtime()

        log.debug('_evalString(%s, %s)' % (datetimeString, sourceTime))

        # Given string date is a RFC822 date
        if sourceTime is None:
            sourceTime = _parse_date_rfc822(s)
            log.debug('attempt to parse as rfc822 - %s' % str(sourceTime))

            if sourceTime is not None:
                (yr, mth, dy, hr, mn, sec, wd, yd, isdst, _) = sourceTime
                self.dateFlag = 1

                if (hr != 0) and (mn != 0) and (sec != 0):
                    self.timeFlag = 2

                sourceTime = (yr, mth, dy, hr, mn, sec, wd, yd, isdst)

        # Given string date is a W3CDTF date
        if sourceTime is None:
            sourceTime = _parse_date_w3dtf(s)

            if sourceTime is not None:
                self.dateFlag = 1
                self.timeFlag = 2

        if sourceTime is None:
            s = s.lower()

        # Given string is in the format HH:MM(:SS)(am/pm)
        if self.meridianFlag:
            if sourceTime is None:
                (yr, mth, dy, hr, mn, sec, wd, yd, isdst) = now
            else:
                (yr, mth, dy, hr, mn, sec, wd, yd, isdst) = sourceTime

            m = self.ptc.CRE_TIMEHMS2.search(s)
            if m is not None:
                dt = s[:m.start('meridian')].strip()
                if len(dt) <= 2:
                    hr  = int(dt)
                    mn  = 0
                    sec = 0
                else:
                    hr, mn, sec = _extract_time(m)

                if hr == 24:
                    hr = 0

                sourceTime = (yr, mth, dy, hr, mn, sec, wd, yd, isdst)
                meridian   = m.group('meridian').lower()

                  # if 'am' found and hour is 12 - force hour to 0 (midnight)
                if (meridian in self.ptc.am) and hr == 12:
                    sourceTime = (yr, mth, dy, 0, mn, sec, wd, yd, isdst)

                  # if 'pm' found and hour < 12, add 12 to shift to evening
                if (meridian in self.ptc.pm) and hr < 12:
                    sourceTime = (yr, mth, dy, hr + 12, mn, sec, wd, yd, isdst)

              # invalid time
            if hr > 24 or mn > 59 or sec > 59:
                sourceTime    = now
                self.dateFlag = 0
                self.timeFlag = 0

            self.meridianFlag = False

        # Given string is in the format HH:MM(:SS)
        if self.timeStdFlag:
            if sourceTime is None:
                (yr, mth, dy, hr, mn, sec, wd, yd, isdst) = now
            else:
                (yr, mth, dy, hr, mn, sec, wd, yd, isdst) = sourceTime

            m = self.ptc.CRE_TIMEHMS.search(s)
            if m is not None:
                hr, mn, sec = _extract_time(m)
            if hr == 24:
                hr = 0

            if hr > 24 or mn > 59 or sec > 59:
                # invalid time
                sourceTime    = now
                self.dateFlag = 0
                self.timeFlag = 0
            else:
                sourceTime = (yr, mth, dy, hr, mn, sec, wd, yd, isdst)

            self.timeStdFlag = False

        # Given string is in the format 07/21/2006
        if self.dateStdFlag:
            sourceTime       = self.parseDate(s, sourceTime)
            self.dateStdFlag = False

        # Given string is in the format  "May 23rd, 2005"
        if self.dateStrFlag:
            log.debug('checking for MMM DD YYYY')
            sourceTime       = self.parseDateText(s, sourceTime)
            log.debug('parseDateText(%s) returned %s' % (s, sourceTime))
            self.dateStrFlag = False

        # Given string is a weekday
        if self.weekdyFlag:
            log.debug('weekdyFlag is set')
            if sourceTime is None:
                (yr, mth, dy, hr, mn, sec, wd, yd, isdst) = now
            else:
                (yr, mth, dy, hr, mn, sec, wd, yd, isdst) = sourceTime

            start = datetime.datetime(yr, mth, dy, hr, mn, sec)
            wkdy  = self.ptc.WeekdayOffsets[s]

            if wkdy > wd:
                qty = self._CalculateDOWDelta(wd, wkdy, 2,
                                              self.ptc.DOWParseStyle,
                                              self.ptc.CurrentDOWParseStyle)
            else:
                qty = self._CalculateDOWDelta(wd, wkdy, 2,
                                              self.ptc.DOWParseStyle,
                                              self.ptc.CurrentDOWParseStyle)

            target = start + datetime.timedelta(days=qty)
            wd     = wkdy

            sourceTime      = target.timetuple()
            self.weekdyFlag = False

        # Given string is a natural language time string like
        # lunch, midnight, etc
        if self.timeStrFlag:
            log.debug('timeStrFlag is set')
            if s in self.ptc.re_values['now']:
                sourceTime = now
            else:
                sources = self.ptc.buildSources(sourceTime)

                if s in sources:
                    sourceTime = sources[s]
                else:
                    sourceTime    = now
                    self.dateFlag = 0
                    self.timeFlag = 0

            self.timeStrFlag = False

        # Given string is a natural language date string like today, tomorrow..
        if self.dayStrFlag:
            log.debug('dayStrFlag is set')
            if sourceTime is None:
                sourceTime = now

            (yr, mth, dy, hr, mn, sec, wd, yd, isdst) = sourceTime

            if s in self.ptc.dayOffsets:
                offset = self.ptc.dayOffsets[s]
            else:
                offset = 0

            start      = datetime.datetime(yr, mth, dy, 9, 0, 0)
            target     = start + datetime.timedelta(days=offset)
            sourceTime = target.timetuple()

            self.dayStrFlag = False

        # Given string is a time string with units like "5 hrs 30 min"
        if self.unitsFlag:
            log.debug('unitsFlag is set')
            modifier = ''  # TODO

            if sourceTime is None:
                sourceTime = now

            m = self.ptc.CRE_UNITS.search(s)
            if m is not None:
                units    = m.group('units')
                quantity = s[:m.start('units')]

            sourceTime     = self._buildTime(sourceTime, quantity, modifier, units)
            self.unitsFlag = False

        # Given string is a time string with single char units like "5 h 30 m"
        if self.qunitsFlag:
            log.debug('qunitsFlag is set')
            modifier = ''  # TODO

            if sourceTime is None:
                sourceTime = now

            m = self.ptc.CRE_QUNITS.search(s)
            if m is not None:
                units    = m.group('qunits')
                quantity = s[:m.start('qunits')]

            sourceTime      = self._buildTime(sourceTime, quantity, modifier, units)
            self.qunitsFlag = False

          # Given string does not match anything
        if sourceTime is None:
            log.debug('sourceTime is None - setting to current date')
            sourceTime    = now
            self.dateFlag = 0
            self.timeFlag = 0

        return sourceTime

    def _UnitsTrapped(self, s, m, key):
        # check if a day suffix got trapped by a unit match
        # for example Dec 31st would match for 31s (aka 31 seconds)
        # Dec 31st
        #     ^ ^
        #     | +-- m.start('units')
        #     |     and also m2.start('suffix')
        #     +---- m.start('qty')
        #           and also m2.start('day')
        m2 = self.ptc.CRE_DAY2.search(s)
        if m2 is not None:
            t = '%s%s' % (m2.group('day'), m.group(key))
            if ((m.start(key)   == m2.start('suffix')) and
                (m.start('qty') == m2.start('day')) and
                (m.group('qty') == t)):
                return True
            else:
                return False
        else:
            return False

    def parseDT(self, datetimeString, sourceTime=None, tzinfo=None):
        """
        C{datetimeString} is as C{.parse}, C{sourceTime} has the same semantic
        meaning as C{.parse}, but now also accepts datetime objects.  C{tzinfo}
        accepts a tzinfo object.  It is advisable to use pytz.


        @type  datetimeString: string
        @param datetimeString: date/time text to evaluate
        @type  sourceTime:     struct_time, datetime, date, time
        @param sourceTime:     time value to use as the base
        @type  tzinfo:         tzinfo
        @param tzinfo:         Timezone to apply to generated datetime objs.

        @rtype:  tuple
        @return: tuple of datetime object and an int of the return code

        see .parse for return code details.
        """
        # if sourceTime has a timetuple method, use thet, else, just pass the
        # entire thing to parse and prey the user knows what the hell they are
        # doing.
        sourceTime = getattr(sourceTime, 'timetuple', (lambda: sourceTime))()
        # You REALLY SHOULD be using pytz.  Using localize if available,
        # hacking if not.  Note, None is a valid tzinfo object in the case of
        # the ugly hack.
        localize = getattr(
            tzinfo,
            'localize',
            (lambda dt: dt.replace(tzinfo=tzinfo)),  # ugly hack is ugly :(
        )

        # Punt
        time_struct, ret_code = self.parse(
            datetimeString,
            sourceTime=sourceTime
        )

        # Comments from GHI indicate that it is desired to have the same return
        # signature on this method as that one it punts to, with the exception
        # of using datetime objects instead of time_structs.
        dt = localize(datetime.datetime(*time_struct[:6]))
        return (dt, ret_code)

    def parse(self, datetimeString, sourceTime=None):
        """
        Splits the given C{datetimeString} into tokens, finds the regex
        patterns that match and then calculates a C{struct_time} value from
        the chunks.

        If C{sourceTime} is given then the C{struct_time} value will be
        calculated from that value, otherwise from the current date/time.

        If the C{datetimeString} is parsed and date/time value found then
        the second item of the returned tuple will be a flag to let you know
        what kind of C{struct_time} value is being returned::

            0 = not parsed at all
            1 = parsed as a C{date}
            2 = parsed as a C{time}
            3 = parsed as a C{datetime}

        @type  datetimeString: string
        @param datetimeString: date/time text to evaluate
        @type  sourceTime:     struct_time
        @param sourceTime:     C{struct_time} value to use as the base

        @rtype:  tuple
        @return: tuple of: modified C{sourceTime} and the result flag
        """
        log.debug('parse()')

        datetimeString = re.sub(r'(\w)(\.)(\s)', r'\1\3', datetimeString)
        datetimeString = re.sub(r'(\w)(\'|")(\s|$)', r'\1 \3', datetimeString)
        datetimeString = re.sub(r'(\s|^)(\'|")(\w)', r'\1 \3', datetimeString)

        if sourceTime:
            if isinstance(sourceTime, datetime.datetime):
                log.debug('coercing datetime to timetuple')
                sourceTime = sourceTime.timetuple()
            else:
                if not isinstance(sourceTime, time.struct_time) and \
                   not isinstance(sourceTime, tuple):
                    raise Exception('sourceTime is not a struct_time')

        s         = datetimeString.strip().lower()
        parseStr  = ''
        totalTime = sourceTime

        if s == '' :
            if sourceTime is not None:
                return (sourceTime, self.dateFlag + self.timeFlag)
            else:
                return (time.localtime(), 0)

        self.timeFlag = 0
        self.dateFlag = 0

        while len(s) > 0:
            flag   = False
            chunk1 = ''
            chunk2 = ''

            log.debug('parse (top of loop): [%s][%s]' % (s, parseStr))

            if parseStr == '':
                # Modifier like next\prev..
                m = self.ptc.CRE_MODIFIER.search(s)
                if m is not None:
                    self.modifierFlag = True
                    if (m.group('modifier') != s):
                        # capture remaining string
                        parseStr = m.group('modifier')
                        chunk1   = s[:m.start('modifier')].strip()
                        chunk2   = s[m.end('modifier'):].strip()
                        flag     = True
                    else:
                        parseStr = s

            log.debug('parse 1 [%s][%s][%s]' % (parseStr, chunk1, chunk2))

            if parseStr == '':
                # Modifier like from\after\prior..
                m = self.ptc.CRE_MODIFIER2.search(s)
                if m is not None:
                    self.modifier2Flag = True
                    if (m.group('modifier') != s):
                        # capture remaining string
                        parseStr = m.group('modifier')
                        chunk1   = s[:m.start('modifier')].strip()
                        chunk2   = s[m.end('modifier'):].strip()
                        flag     = True
                    else:
                        parseStr = s

            log.debug('parse 2 [%s][%s][%s]' % (parseStr, chunk1, chunk2))

            if parseStr == '':
                # Quantity + Units
                m = self.ptc.CRE_UNITS.search(s)
                if m is not None:
                    log.debug('CRE_UNITS matched')
                    if self._UnitsTrapped(s, m, 'units'):
                        log.debug('day suffix trapped by unit match')
                    else:
                        self.unitsFlag = True
                        if (m.group('qty') != s):
                            # capture remaining string
                            parseStr = m.group('qty')
                            chunk1   = s[:m.start('qty')].strip()
                            chunk2   = s[m.end('qty'):].strip()

                            if chunk1[-1:] == '-':
                                parseStr = '-%s' % parseStr
                                chunk1   = chunk1[:-1]

                            s    = '%s %s' % (chunk1, chunk2)
                            flag = True
                        else:
                            parseStr = s

            log.debug('parse 3 [%s][%s][%s]' % (parseStr, chunk1, chunk2))

            if parseStr == '':
                # Quantity + Units
                m = self.ptc.CRE_QUNITS.search(s)
                if m is not None:
                    log.debug('CRE_QUNITS matched')
                    if self._UnitsTrapped(s, m, 'qunits'):
                        log.debug('day suffix trapped by qunit match')
                    else:
                        self.qunitsFlag = True

                        if (m.group('qty') != s):
                            # capture remaining string
                            parseStr = m.group('qty')
                            chunk1   = s[:m.start('qty')].strip()
                            chunk2   = s[m.end('qty'):].strip()

                            if chunk1[-1:] == '-':
                                parseStr = '-%s' % parseStr
                                chunk1   = chunk1[:-1]

                            s    = '%s %s' % (chunk1, chunk2)
                            flag = True
                        else:
                            parseStr = s

            log.debug('parse 4 [%s][%s][%s]' % (parseStr, chunk1, chunk2))

            if parseStr == '':
                valid_date = False
                for match in self.ptc.CRE_DATE3.finditer(s):
                    # to prevent "HH:MM(:SS) time strings" expressions from triggering
                    # this regex, we checks if the month field exists in the searched
                    # expression, if it doesn't exist, the date field is not valid
                    if match.group('mthname'):
                        m = self.ptc.CRE_DATE3.search(s, match.start())
                        valid_date = True
                        break

                # String date format
                if valid_date:
                    self.dateStrFlag = True
                    self.dateFlag    = 1

                    if (m.group('date') != s):
                        # capture remaining string
                        mStart   = m.start('date')
                        mEnd     = m.end('date')
                        parseStr = m.group('date')
                        chunk1   = s[:mStart]
                        chunk2   = s[mEnd:]

                        # we need to check that anything following the parsed date
                        # is a time expression because it is often picked up as
                        # a valid year if the hour is 2 digits
                        fTime = False
                        mm    = self.ptc.CRE_TIMEHMS2.search(s)
                        # "February 24th 1PM" doesn't get caught
                        # "February 24th 12PM" does
                        if mm is not None and m.group('year') is not None:
                            fTime = True
                        else:
                            # "February 24th 12:00"
                            mm = self.ptc.CRE_TIMEHMS.search(s)
                            if mm is not None and m.group('year') is None:
                                fTime = True
                        if fTime:
                            n      = mm.end('hours') - mm.start('hours')
                            sEnd   = parseStr[-n:]
                            sStart = mm.group('hours')

                            if sStart == sEnd:
                                parseStr = parseStr[:mEnd - n].strip()
                                chunk2   = s[mEnd - n:]

                        s    = '%s %s' % (chunk1, chunk2)
                        flag = True
                    else:
                        parseStr = s

            log.debug('parse 5 [%s][%s][%s]' % (parseStr, chunk1, chunk2))

            if parseStr == '':
                # Standard date format
                m = self.ptc.CRE_DATE.search(s)
                if m is not None:
                    self.dateStdFlag = True
                    self.dateFlag    = 1
                    if (m.group('date') != s):
                        # capture remaining string
                        parseStr = m.group('date')
                        chunk1   = s[:m.start('date')]
                        chunk2   = s[m.end('date'):]
                        s        = '%s %s' % (chunk1, chunk2)
                        flag     = True
                    else:
                        parseStr = s

            log.debug('parse 6 [%s][%s][%s]' % (parseStr, chunk1, chunk2))

            if parseStr == '':
                # Natural language day strings
                m = self.ptc.CRE_DAY.search(s)
                if m is not None:
                    self.dayStrFlag = True
                    self.dateFlag   = 1
                    if (m.group('day') != s):
                        # capture remaining string
                        parseStr = m.group('day')
                        chunk1   = s[:m.start('day')]
                        chunk2   = s[m.end('day'):]
                        s        = '%s %s' % (chunk1, chunk2)
                        flag     = True
                    else:
                        parseStr = s

            log.debug('parse 7 [%s][%s][%s]' % (parseStr, chunk1, chunk2))

            if parseStr == '':
                # Weekday
                m = self.ptc.CRE_WEEKDAY.search(s)
                if m is not None:
                    gv = m.group('weekday')
                    if s not in self.ptc.dayOffsets:
                        self.weekdyFlag = True
                        self.dateFlag   = 1
                        if (gv != s):
                            # capture remaining string
                            parseStr = gv
                            chunk1   = s[:m.start('weekday')]
                            chunk2   = s[m.end('weekday'):]
                            s        = '%s %s' % (chunk1, chunk2)
                            flag     = True
                        else:
                            parseStr = s

            log.debug('parse 8 [%s][%s][%s]' % (parseStr, chunk1, chunk2))

            if parseStr == '':
                # Natural language time strings
                m = self.ptc.CRE_TIME.search(s)
                if m is not None or s in self.ptc.re_values['now']:
                    self.timeStrFlag = True
                    self.timeFlag    = 2
                    if (m and m.group('time') != s):
                        # capture remaining string
                        parseStr = m.group('time')
                        chunk1   = s[:m.start('time')]
                        chunk2   = s[m.end('time'):]
                        s        = '%s %s' % (chunk1, chunk2)
                        flag     = True
                    else:
                        parseStr = s

            log.debug('parse 9 [%s][%s][%s]' % (parseStr, chunk1, chunk2))

            if parseStr == '':
                # HH:MM(:SS) am/pm time strings
                m = self.ptc.CRE_TIMEHMS2.search(s)
                if m is not None:
                    self.meridianFlag = True
                    self.timeFlag     = 2
                    if m.group('minutes') is not None:
                        if m.group('seconds') is not None:
                            parseStr = '%s:%s:%s %s' % (m.group('hours'),
                                                        m.group('minutes'),
                                                        m.group('seconds'),
                                                        m.group('meridian'))
                        else:
                            parseStr = '%s:%s %s' % (m.group('hours'),
                                                     m.group('minutes'),
                                                     m.group('meridian'))
                    else:
                        parseStr = '%s %s' % (m.group('hours'),
                                              m.group('meridian'))

                    chunk1 = s[:m.start('hours')]
                    chunk2 = s[m.end('meridian'):]

                    s    = '%s %s' % (chunk1, chunk2)
                    flag = True

            log.debug('parse A [%s][%s][%s]' % (parseStr, chunk1, chunk2))

            if parseStr == '':
                # HH:MM(:SS) time strings
                m = self.ptc.CRE_TIMEHMS.search(s)
                if m is not None:
                    self.timeStdFlag = True
                    self.timeFlag    = 2
                    if m.group('seconds') is not None:
                        parseStr = '%s:%s:%s' % (m.group('hours'),
                                                 m.group('minutes'),
                                                 m.group('seconds'))
                        chunk1   = s[:m.start('hours')]
                        chunk2   = s[m.end('seconds'):]
                    else:
                        parseStr = '%s:%s' % (m.group('hours'),
                                              m.group('minutes'))
                        chunk1   = s[:m.start('hours')]
                        chunk2   = s[m.end('minutes'):]

                    s    = '%s %s' % (chunk1, chunk2)
                    flag = True

            # if string does not match any regex, empty string to
            # come out of the while loop
            if not flag:
                s = ''

            log.debug('parse (bottom) [%s][%s][%s][%s]' % (s, parseStr, chunk1, chunk2))
            log.debug('weekday %s, dateStd %s, dateStr %s, time %s, timeStr %s, meridian %s' % \
                      (self.weekdyFlag, self.dateStdFlag, self.dateStrFlag, self.timeStdFlag, self.timeStrFlag, self.meridianFlag))
            log.debug('dayStr %s, modifier %s, modifier2 %s, units %s, qunits %s' % \
                      (self.dayStrFlag, self.modifierFlag, self.modifier2Flag, self.unitsFlag, self.qunitsFlag))

            # evaluate the matched string

            if parseStr != '':
                if self.modifierFlag == True:
                    t, totalTime = self._evalModifier(parseStr, chunk1, chunk2, totalTime)
                    # t is the unparsed part of the chunks.
                    # If it is not date/time, return current
                    # totalTime as it is; else return the output
                    # after parsing t.
                    if (t != '') and (t != None):
                        tempDateFlag       = self.dateFlag
                        tempTimeFlag       = self.timeFlag
                        (totalTime2, flag) = self.parse(t, totalTime)

                        if flag == 0 and totalTime is not None:
                            self.timeFlag = tempTimeFlag
                            self.dateFlag = tempDateFlag

                            log.debug('return 1')
                            return (totalTime, self.dateFlag + self.timeFlag)
                        else:
                            log.debug('return 2')
                            return (totalTime2, self.dateFlag + self.timeFlag)

                elif self.modifier2Flag == True:
                    totalTime, invalidFlag = self._evalModifier2(parseStr, chunk1, chunk2, totalTime)
                    if invalidFlag == True:
                        self.dateFlag = 0
                        self.timeFlag = 0

                else:
                    totalTime = self._evalString(parseStr, totalTime)
                    parseStr  = ''

        # String is not parsed at all
        if totalTime is None:
            log.debug('not parsed [%s]' % str(totalTime))
            totalTime     = time.localtime()
            self.dateFlag = 0
            self.timeFlag = 0
        log.debug('parse() return dateFlag %d timeFlag %d totalTime %s' % (self.dateFlag, self.timeFlag, totalTime))
        return (totalTime, self.dateFlag + self.timeFlag)

    def inc(self, source, month=None, year=None):
        """
        Takes the given C{source} date, or current date if none is
        passed, and increments it according to the values passed in
        by month and/or year.

        This routine is needed because Python's C{timedelta()} function
        does not allow for month or year increments.

        @type  source: struct_time
        @param source: C{struct_time} value to increment
        @type  month:  integer
        @param month:  optional number of months to increment
        @type  year:   integer
        @param year:   optional number of years to increment

        @rtype:  datetime
        @return: C{source} incremented by the number of months and/or years
        """
        yr  = source.year
        mth = source.month
        dy  = source.day

        if year:
            try:
                yi = int(year)
            except ValueError:
                yi = 0

            yr += yi

        if month:
            try:
                mi = int(month)
            except ValueError:
                mi = 0

            m = abs(mi)
            y = m // 12     # how many years are in month increment
            m = m % 12      # get remaining months

            if mi < 0:
                y *= -1                 # otherwise negative mi will give future dates
                mth = mth - m           # sub months from start month
                if mth < 1:             # cross start-of-year?
                    y   -= 1            #   yes - decrement year
                    mth += 12           #         and fix month
            else:
                mth = mth + m           # add months to start month
                if mth > 12:            # cross end-of-year?
                    y   += 1            #   yes - increment year
                    mth -= 12           #         and fix month

            yr += y

            # if the day ends up past the last day of
            # the new month, set it to the last day
            if dy > self.ptc.daysInMonth(mth, yr):
                dy = self.ptc.daysInMonth(mth, yr)

        d = source.replace(year=yr, month=mth, day=dy)

        return source + (d - source)

    def nlp(self, inputString, sourceTime=None):
        """Utilizes parse() after making judgements about what datetime information belongs together.

        It makes logical groupings based on proximity and returns a parsed datetime for each matched grouping of
        datetime text, along with location info within the given inputString.

        @type  inputString: string
        @param inputString: natural language text to evaluate
        @type  sourceTime:  struct_time
        @param sourceTime:  C{struct_time} value to use as the base

        @rtype:  tuple or None
        @return: tuple of tuples in the format (parsed_datetime as datetime.datetime, flags as int, start_pos as int,
                 end_pos as int, matched_text as string) or None if there were no matches
        """

        orig_inputstring = inputString

        # replace periods at the end of sentences w/ spaces
        # opposed to removing them altogether in order to
        # retain relative positions (identified by alpha, period, space).
        # this is required for some of the regex patterns to match
        inputString = re.sub(r'(\w)(\.)(\s)', r'\1 \3', inputString).lower()
        inputString = re.sub(r'(\w)(\'|")(\s|$)', r'\1 \3', inputString)
        inputString = re.sub(r'(\s|^)(\'|")(\w)', r'\1 \3', inputString)

        startpos = 0  # the start position in the inputString during the loop

        matches = []  # list of lists in format: [startpos, endpos, matchedstring, flags, type]

        while startpos < len(inputString):

            # empty match
            leftmost_match = [0, 0, None, 0, None]

            # Modifier like next\prev..
            m = self.ptc.CRE_MODIFIER.search(inputString[startpos:])
            if m is not None:
                if leftmost_match[1] == 0 or leftmost_match[0] > m.start('modifier') + startpos:
                    leftmost_match[0] = m.start('modifier') + startpos
                    leftmost_match[1] = m.end('modifier') + startpos
                    leftmost_match[2] = m.group('modifier')
                    leftmost_match[3] = 0
                    leftmost_match[4] = 'modifier'

            # Modifier like from\after\prior..
            m = self.ptc.CRE_MODIFIER2.search(inputString[startpos:])
            if m is not None:
                if leftmost_match[1] == 0 or leftmost_match[0] > m.start('modifier') + startpos:
                    leftmost_match[0] = m.start('modifier') + startpos
                    leftmost_match[1] = m.end('modifier') + startpos
                    leftmost_match[2] = m.group('modifier')
                    leftmost_match[3] = 0
                    leftmost_match[4] = 'modifier2'

            # Quantity + Units
            m = self.ptc.CRE_UNITS.search(inputString[startpos:])
            if m is not None:
                log.debug('CRE_UNITS matched')
                if self._UnitsTrapped(inputString[startpos:], m, 'units'):
                    log.debug('day suffix trapped by unit match')
                else:

                    if leftmost_match[1] == 0 or leftmost_match[0] > m.start('qty') + startpos:
                        leftmost_match[0] = m.start('qty') + startpos
                        leftmost_match[1] = m.end('qty') + startpos
                        leftmost_match[2] = m.group('qty')
                        leftmost_match[3] = 3
                        leftmost_match[4] = 'units'

                        if m.start('qty') > 0 and inputString[m.start('qty') - 1] == '-':
                            leftmost_match[0] = leftmost_match[0] - 1
                            leftmost_match[2] = '-' + leftmost_match[2]

            # Quantity + Units
            m = self.ptc.CRE_QUNITS.search(inputString[startpos:])
            if m is not None:
                log.debug('CRE_QUNITS matched')
                if self._UnitsTrapped(inputString[startpos:], m, 'qunits'):
                    log.debug('day suffix trapped by qunit match')
                else:
                    if leftmost_match[1] == 0 or leftmost_match[0] > m.start('qty') + startpos:
                        leftmost_match[0] = m.start('qty') + startpos
                        leftmost_match[1] = m.end('qty') + startpos
                        leftmost_match[2] = m.group('qty')
                        leftmost_match[3] = 3
                        leftmost_match[4] = 'qunits'

                        if m.start('qty') > 0 and inputString[m.start('qty') - 1] == '-':
                            leftmost_match[0] = leftmost_match[0] - 1
                            leftmost_match[2] = '-' + leftmost_match[2]

            valid_date = False
            for match in self.ptc.CRE_DATE3.finditer(inputString[startpos:]):
                # to prevent "HH:MM(:SS) time strings" expressions from triggering
                # this regex, we checks if the month field exists in the searched
                # expression, if it doesn't exist, the date field is not valid
                if match.group('mthname'):
                    m = self.ptc.CRE_DATE3.search(inputString[startpos:], match.start())
                    valid_date = True
                    break

            # String date format
            if valid_date:
                if leftmost_match[1] == 0 or leftmost_match[0] > m.start('date') + startpos:
                    leftmost_match[0] = m.start('date') + startpos
                    leftmost_match[1] = m.end('date') + startpos
                    leftmost_match[2] = m.group('date')
                    leftmost_match[3] = 1
                    leftmost_match[4] = 'dateStr'

            # Standard date format
            m = self.ptc.CRE_DATE.search(inputString[startpos:])
            if m is not None:
                if leftmost_match[1] == 0 or leftmost_match[0] > m.start('date') + startpos:
                    leftmost_match[0] = m.start('date') + startpos
                    leftmost_match[1] = m.end('date') + startpos
                    leftmost_match[2] = m.group('date')
                    leftmost_match[3] = 1
                    leftmost_match[4] = 'dateStd'

            # Natural language day strings
            m = self.ptc.CRE_DAY.search(inputString[startpos:])
            if m is not None:
                if leftmost_match[1] == 0 or leftmost_match[0] > m.start('day') + startpos:
                    leftmost_match[0] = m.start('day') + startpos
                    leftmost_match[1] = m.end('day') + startpos
                    leftmost_match[2] = m.group('day')
                    leftmost_match[3] = 1
                    leftmost_match[4] = 'dayStr'

            # Weekday
            m = self.ptc.CRE_WEEKDAY.search(inputString[startpos:])
            if m is not None:
                if inputString[startpos:] not in self.ptc.dayOffsets:
                    if leftmost_match[1] == 0 or leftmost_match[0] > m.start('weekday') + startpos:
                        leftmost_match[0] = m.start('weekday') + startpos
                        leftmost_match[1] = m.end('weekday') + startpos
                        leftmost_match[2] = m.group('weekday')
                        leftmost_match[3] = 1
                        leftmost_match[4] = 'weekdy'

            # Natural language time strings
            m = self.ptc.CRE_TIME.search(inputString[startpos:])
            if m is not None:
                if leftmost_match[1] == 0 or leftmost_match[0] > m.start('time') + startpos:
                    leftmost_match[0] = m.start('time') + startpos
                    leftmost_match[1] = m.end('time') + startpos
                    leftmost_match[2] = m.group('time')
                    leftmost_match[3] = 2
                    leftmost_match[4] = 'timeStr'

            # HH:MM(:SS) am/pm time strings
            m = self.ptc.CRE_TIMEHMS2.search(inputString[startpos:])
            if m is not None:
                if leftmost_match[1] == 0 or leftmost_match[0] > m.start('hours') + startpos:
                    leftmost_match[0] = m.start('hours') + startpos
                    leftmost_match[1] = m.end('meridian') + startpos
                    leftmost_match[2] = inputString[leftmost_match[0]:leftmost_match[1]]
                    leftmost_match[3] = 2
                    leftmost_match[4] = 'meridian'

            # HH:MM(:SS) time strings
            m = self.ptc.CRE_TIMEHMS.search(inputString[startpos:])
            if m is not None:
                if leftmost_match[1] == 0 or leftmost_match[0] > m.start('hours') + startpos:
                    leftmost_match[0] = m.start('hours') + startpos
                    if m.group('seconds') is not None:
                        leftmost_match[1] = m.end('seconds') + startpos
                    else:
                        leftmost_match[1] = m.end('minutes') + startpos
                    leftmost_match[2] = inputString[leftmost_match[0]:leftmost_match[1]]
                    leftmost_match[3] = 2
                    leftmost_match[4] = 'timeStd'

            # set the start position to the end pos of the leftmost match
            startpos = leftmost_match[1]

            # nothing was detected
            # so break out of the loop
            if startpos == 0:
                startpos = len(inputString)
            else:
                if leftmost_match[3] > 0:
                    m = self.ptc.CRE_NLP_PREFIX.search(inputString[:leftmost_match[0]] + ' ' + str(leftmost_match[3]))
                    if m is not None:
                        leftmost_match[0] = m.start('nlp_prefix')
                        leftmost_match[2] = inputString[leftmost_match[0]:leftmost_match[1]]
                matches.append(leftmost_match)

        # find matches in proximity with one another and return all the parsed values
        proximity_matches = []
        if len(matches) > 1:
            combined = ''
            from_match_index = 0
            modifier1 = matches[0][4] == 'modifier'
            modifier2 = matches[0][4] == 'modifier2'
            date = matches[0][3] == 1
            time = matches[0][3] == 2
            units = matches[0][3] == 3
            for i in range(1, len(matches)):

                # test proximity (are there characters between matches?)
                endofprevious = matches[i - 1][1]
                begofcurrent = matches[i][0]
                if orig_inputstring[endofprevious:begofcurrent].lower().strip() != '':
                    # this one isn't in proximity, but maybe
                    # we have enough to make a datetime
                    # todo: make sure the combination of formats (modifier, dateStd, etc) makes logical sense before parsing together
                    if date or time:
                        combined = orig_inputstring[matches[from_match_index][0]:matches[i - 1][1]]
                        parsed_datetime, flags = self.parse(combined, sourceTime)
                        proximity_matches.append((datetime.datetime(parsed_datetime[0], parsed_datetime[1], parsed_datetime[2], parsed_datetime[3], parsed_datetime[4], parsed_datetime[5]), flags, matches[from_match_index][0], matches[i - 1][1], combined))
                        #proximity_matches.append((parsed_datetime, flags, matches[from_match_index][0], matches[i - 1][1], combined))
                    # not in proximity, reset starting from current
                    from_match_index = i
                    modifier1 = matches[i][4] == 'modifier'
                    modifier2 = matches[i][4] == 'modifier2'
                    date = matches[i][3] == 1
                    time = matches[i][3] == 2
                    units = matches[i][3] == 3
                    continue
                else:
                    if matches[i][4] == 'modifier':
                        modifier1 = True
                    if matches[i][4] == 'modifier2':
                        modifier2 = True
                    if matches[i][3] == 1:
                        date = True
                    if matches[i][3] == 2:
                        time = True
                    if matches[i][3] == 3:
                        units = True

            # check last
            # we have enough to make a datetime
            if date or time or units:

                combined = orig_inputstring[matches[from_match_index][0]:matches[len(matches) - 1][1]]
                parsed_datetime, flags = self.parse(combined, sourceTime)
                proximity_matches.append((datetime.datetime(parsed_datetime[0], parsed_datetime[1], parsed_datetime[2], parsed_datetime[3], parsed_datetime[4], parsed_datetime[5]), flags, matches[from_match_index][0], matches[len(matches) - 1][1], combined))
                #proximity_matches.append((parsed_datetime, flags, matches[from_match_index][0], matches[len(matches) - 1][1], combined))

        elif len(matches) == 0:
            return None
        else:
            if matches[0][3] == 0:  # not enough info to parse
                return None
            else:
                parsed_datetime, flags = self.parse(matches[0][2], sourceTime)
                proximity_matches.append((datetime.datetime(parsed_datetime[0], parsed_datetime[1], parsed_datetime[2], parsed_datetime[3], parsed_datetime[4], parsed_datetime[5]), flags, matches[0][0], matches[0][1], matches[0][2]))
                #proximity_matches.append((parsed_datetime, flags, matches[0][0], matches[0][1], matches[0][2]))

        return tuple(proximity_matches)


def _initSymbols(ptc):
    """
    Initialize symbols and single character constants.
    """
      # build am and pm lists to contain
      # original case, lowercase, first-char and dotted
      # versions of the meridian text

    if len(ptc.locale.meridian) > 0:
        am     = ptc.locale.meridian[0]
        ptc.am = [ am ]

        if len(am) > 0:
            ptc.am.append(am[0])
            ptc.am.append('{0}.{1}.'.format(am[0], am[1]))
            am = am.lower()
            ptc.am.append(am)
            ptc.am.append(am[0])
            ptc.am.append('{0}.{1}.'.format(am[0], am[1]))
    else:
        am     = ''
        ptc.am = [ '', '' ]

    if len(ptc.locale.meridian) > 1:
        pm     = ptc.locale.meridian[1]
        ptc.pm = [ pm ]

        if len(pm) > 0:
            ptc.pm.append(pm[0])
            ptc.pm.append('{0}.{1}.'.format(pm[0], pm[1]))
            pm = pm.lower()
            ptc.pm.append(pm)
            ptc.pm.append(pm[0])
            ptc.pm.append('{0}.{1}.'.format(pm[0], pm[1]))
    else:
        pm     = ''
        ptc.pm = [ '', '' ]


class Constants(object):
    """
    Default set of constants for parsedatetime.

    If PyICU is present, then the class will first try to get PyICU
    to return a locale specified by C{localeID}.  If either C{localeID} is
    None or if the locale does not exist within PyICU, then each of the
    locales defined in C{fallbackLocales} is tried in order.

    If PyICU is not present or none of the specified locales can be used,
    then the class will initialize itself to the en_US locale.

    if PyICU is not present or not requested, only the locales defined by
    C{pdtLocales} will be searched.
    """
    def __init__(self, localeID=None, usePyICU=True, fallbackLocales=['en_US']):
        self.localeID        = localeID
        self.fallbackLocales = fallbackLocales

        if 'en_US' not in self.fallbackLocales:
            self.fallbackLocales.append('en_US')

          # define non-locale specific constants

        self.locale   = None
        self.usePyICU = usePyICU

        # starting cache of leap years
        # daysInMonth will add to this if during
        # runtime it gets a request for a year not found
        self._leapYears = [ 1904, 1908, 1912, 1916, 1920, 1924, 1928, 1932, 1936, 1940, 1944,
                            1948, 1952, 1956, 1960, 1964, 1968, 1972, 1976, 1980, 1984, 1988,
                            1992, 1996, 2000, 2004, 2008, 2012, 2016, 2020, 2024, 2028, 2032,
                            2036, 2040, 2044, 2048, 2052, 2056, 2060, 2064, 2068, 2072, 2076,
                            2080, 2084, 2088, 2092, 2096 ]

        self.Second =   1
        self.Minute =  60 * self.Second
        self.Hour   =  60 * self.Minute
        self.Day    =  24 * self.Hour
        self.Week   =   7 * self.Day
        self.Month  =  30 * self.Day
        self.Year   = 365 * self.Day

        self._DaysInMonthList = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
        self.rangeSep         = '-'
        self.BirthdayEpoch    = 50

        # YearParseStyle controls how we parse "Jun 12", i.e. dates that do
        # not have a year present.  The default is to compare the date given
        # to the current date, and if prior, then assume the next year.
        # Setting this to 0 will prevent that.

        self.YearParseStyle = 1

        # DOWParseStyle controls how we parse "Tuesday"
        # If the current day was Thursday and the text to parse is "Tuesday"
        # then the following table shows how each style would be returned
        # -1, 0, +1
        #
        # Current day marked as ***
        #
        #          Sun Mon Tue Wed Thu Fri Sat
        # week -1
        # current         -1,0     ***
        # week +1          +1
        #
        # If the current day was Monday and the text to parse is "Tuesday"
        # then the following table shows how each style would be returned
        # -1, 0, +1
        #
        #          Sun Mon Tue Wed Thu Fri Sat
        # week -1           -1
        # current      *** 0,+1
        # week +1

        self.DOWParseStyle = 1

        # CurrentDOWParseStyle controls how we parse "Friday"
        # If the current day was Friday and the text to parse is "Friday"
        # then the following table shows how each style would be returned
        # True/False. This also depends on DOWParseStyle.
        #
        # Current day marked as ***
        #
        # DOWParseStyle = 0
        #          Sun Mon Tue Wed Thu Fri Sat
        # week -1
        # current                      T,F
        # week +1
        #
        # DOWParseStyle = -1
        #          Sun Mon Tue Wed Thu Fri Sat
        # week -1                       F
        # current                       T
        # week +1
        #
        # DOWParseStyle = +1
        #
        #          Sun Mon Tue Wed Thu Fri Sat
        # week -1
        # current                       T
        # week +1                       F

        self.CurrentDOWParseStyle = False

        if self.usePyICU:
            self.locale = pdtLocales['icu'](self.localeID)

            if self.locale.icu is None:
                self.usePyICU = False
                self.locale   = None

        if self.locale is None:
            if not self.localeID in pdtLocales:
                for localeId in range(0, len(self.fallbackLocales)):
                    self.localeID = self.fallbackLocales[localeId]
                    if self.localeID in pdtLocales:
                        break

            self.locale = pdtLocales[self.localeID]()

        if self.locale is not None:


            def _getLocaleDataAdjusted(localeData):
                """
                If localeData is defined as ["mon|mnd", 'tu|tues'...] then this function splits those definitions on |
                """
                adjusted = []
                for d in localeData:
                    if len(d.split("|"))>0:
                        adjusted += d.split("|")
                    else:
                        adjusted.append(d)
                return adjusted

            mths = _getLocaleDataAdjusted(self.locale.Months)
            smths = _getLocaleDataAdjusted(self.locale.shortMonths)
            swds = _getLocaleDataAdjusted(self.locale.shortWeekdays)
            wds = _getLocaleDataAdjusted(self.locale.Weekdays)

            # escape any regex special characters that may be found
            self.locale.re_values['months']      = '|'.join(map(re.escape, mths))
            self.locale.re_values['shortmonths'] = '|'.join(map(re.escape, smths))
            self.locale.re_values['days']        = '|'.join(map(re.escape, wds))
            self.locale.re_values['shortdays']   = '|'.join(map(re.escape, swds))
            self.locale.re_values['dayoffsets']  = '|'.join(map(re.escape, self.locale.dayOffsets))
            self.locale.re_values['numbers']     = '|'.join(map(re.escape, self.locale.numbers))

            units = [unit for units in self.locale.units.values() for unit in units] # flatten
            units.sort(key=len, reverse=True) # longest first
            self.locale.re_values['units'] = '|'.join(tuple(map(re.escape, units)))

            l = []
            lbefore = []
            lafter  = []
            for s in self.locale.Modifiers:
                l.append(s)
                if self.locale.Modifiers[s] < 0:
                    lbefore.append(s)
                elif self.locale.Modifiers[s] > 0:
                    lafter.append(s)
            self.locale.re_values['modifiers']        = '|'.join(tuple(map(re.escape, l)))
            self.locale.re_values['modifiers-before'] = '|'.join(tuple(map(re.escape, lbefore)))
            self.locale.re_values['modifiers-after']  = '|'.join(tuple(map(re.escape, lafter)))

            # todo: analyze all the modifiers to figure out which ones truly belong where.
            #       while it is obvious looking at the code that _evalModifier2 should be
            #       handling 'after', it remains to be researched which ones belong where
            #       and how to make it locale-independent
            lmodifiers = []
            lmodifiers2 = []
            for s in self.locale.Modifiers:
                if self.locale.Modifiers[s] < 0 or s in ['after', 'from']:
                    lmodifiers2.append(s)
                elif self.locale.Modifiers[s] > 0:
                    lmodifiers.append(s)
            self.locale.re_values['modifiers-one'] = '|'.join(tuple(map(re.escape, lmodifiers)))
            self.locale.re_values['modifiers-two'] = '|'.join(tuple(map(re.escape, lmodifiers2)))

            l = []
            for s in self.locale.re_sources:
                l.append(s)
            self.locale.re_values['sources'] = '|'.join(tuple(map(re.escape, l)))

              # build weekday offsets - yes, it assumes the Weekday and shortWeekday
              # lists are in the same order and Mon..Sun (Python style)

            def _buildOffsets(offsetDict,localeData, indexStart):
                o = indexStart
                for key in localeData:
                    if key.split("|")>0:
                        for k in key.split("|"):
                            offsetDict[k] = o
                    else:
                        offsetDict[key] = o
                    o += 1
            _buildOffsets( self.locale.WeekdayOffsets,self.locale.Weekdays, 0)
            _buildOffsets( self.locale.WeekdayOffsets,self.locale.shortWeekdays, 0)

              # build month offsets - yes, it assumes the Months and shortMonths
              # lists are in the same order and Jan..Dec
            _buildOffsets( self.locale.MonthOffsets,self.locale.Months, 1)
            _buildOffsets( self.locale.MonthOffsets,self.locale.shortMonths, 1)


            # self.locale.DaySuffixes = self.locale.re_values['daysuffix'].split('|')

        _initSymbols(self)

        # TODO add code to parse the date formats and build the regexes up from sub-parts
        # TODO find all hard-coded uses of date/time seperators

        # not being used in code, but kept in case others are manually utilizing this regex for their own purposes
        self.RE_DATE4     = r'''(?P<date>
                                    (
                                        (
                                            (?P<day>\d\d?)
                                            (?P<suffix>{daysuffix})?
                                            (,)?
                                            (\s)?
                                        )
                                        (?P<mthname>
                                            ({months}|{shortmonths})
                                        )\s?
                                        (?P<year>\d\d
                                            (\d\d)?
                                        )?
                                    )
                                )'''.format(**self.locale.re_values)

        # I refactored DATE3 to fix Issue 16 http://code.google.com/p/parsedatetime/issues/detail?id=16
        # I suspect the final line was for a trailing time - but testing shows it's not needed
        # ptc.RE_DATE3     = r'''(?P<date>((?P<mthname>(%(months)s|%(shortmonths)s))\s?
        #                                  ((?P<day>\d\d?)(\s?|%(daysuffix)s|$)+)?
        #                                  (,\s?(?P<year>\d\d(\d\d)?))?))
        #                        (\s?|$|[^0-9a-zA-Z])''' % ptc.locale.re_values
        # self.RE_DATE3     = r'''(?P<date>(
        #                                   (((?P<mthname>(%(months)s|%(shortmonths)s))|
        #                                   ((?P<day>\d\d?)(?P<suffix>%(daysuffix)s)?))(\s)?){1,2}
        #                                   ((,)?(\s)?(?P<year>\d\d(\d\d)?))?
        #                                  )
        #                         )''' % self.locale.re_values

        # still not completely sure of the behavior of the regex and
        # whether it would be best to consume all possible irrelevant characters
        # before the option groups (but within the {1,3} repetition group
        # or inside of each option group, as it currently does
        # however, right now, all tests are passing that were,
        # including fixing the bug of matching a 4-digit year as ddyy
        # when the day is absent from the string
        self.RE_DATE3     = r'''(?P<date>
                                (
                                        (
                                            (^|\s)
                                            (?P<mthname>
                                                ({months}|{shortmonths})(?![a-zA-Z_])
                                            )
                                        ){{1}}
                                        |
                                        (
                                            (^|\s)
                                            (?P<day>([1-9]|[0-2][0-9]|3[0-1])(?!(\d|pm|am)))
                                            (?P<suffix>{daysuffix})?
                                        ){{1}}
                                        |
                                        (
                                            ,?\s?
                                            (?P<year>\d\d(\d\d)?)
                                        ){{1}}
                                ){{1,3}}
                            )'''.format(**self.locale.re_values)

        # not being used in code, but kept in case others are manually utilizing this regex for their own purposes
        self.RE_MONTH     = r'''(\s|^)
                                (?P<month>
                                    (
                                            (?P<mthname>
                                                ({months}|{shortmonths})
                                            )
                                            (\s?
                                                (?P<year>(\d\d\d\d))
                                            )?
                                    )
                                )
                                (\s|$|[^0-9a-zA-Z])'''.format(**self.locale.re_values)

        self.RE_WEEKDAY   = r'''(\s|^)
                                (?P<weekday>
                                    ({days}|{shortdays})
                                )
                                (\s|$|[^0-9a-zA-Z])'''.format(**self.locale.re_values)

        self.RE_NUMBER    = r'({numbers}|\d+)'.format(**self.locale.re_values)

        self.RE_SPECIAL   = r'(?P<special>^[{specials}]+)\s+'.format(**self.locale.re_values)

        self.RE_UNITS     = r'''(?P<qty>
                                    (-?
                                        (\b
                                            ({numbers})\b|\d+
                                        )\s*
                                        (?P<units>
                                            (\b{units})
                                        )
                                    )
                                )'''.format(**self.locale.re_values)

        self.RE_QUNITS    = r'''(?P<qty>
                                    (-?
                                        (\b
                                            ({numbers}s)\b|\d+
                                        )\s?
                                        \b
                                        (?P<qunits>{qunits})
                                        (\s?|,|$)
                                    )
                                )'''.format(**self.locale.re_values)

        # self.RE_MODIFIER  = r'''(\s?|^)
        #                         (?P<modifier>
        #                          (previous|prev|last|next|eod|eo|(end\sof)|(in\sa)))''' % self.locale.re_values
        # self.RE_MODIFIER2 = r'''(\s?|^)
        #                         (?P<modifier>
        #                          (from|before|after|ago|prior))
        #                         (\s?|$|[^0-9a-zA-Z])''' % self.locale.re_values
        self.RE_MODIFIER  = r'''(\s|^)
                                (?P<modifier>
                                    ({modifiers-one})
                                )'''.format(**self.locale.re_values)

        self.RE_MODIFIER2 = r'''(\s|^)
                                (?P<modifier>
                                    ({modifiers-two})
                                )
                                (\s|$|[^0-9a-zA-Z])'''.format(**self.locale.re_values)

        self.RE_TIMEHMS   = r'''(\s?|^)
                                (?P<hours>\d\d?)
                                (?P<tsep>{timeseperator}|)
                                (?P<minutes>\d\d)
                                (?:(?P=tsep)
                                    (?P<seconds>\d\d
                                        (?:[.,]\d+)?
                                    )
                                )?'''.format(**self.locale.re_values)

        self.RE_TIMEHMS2  = r'''(?P<hours>
                                    (\d\d?)
                                )
                                (
                                    (?P<tsep>{timeseperator}|)
                                    (?P<minutes>
                                        (\d\d?)
                                    )
                                    (?:(?P=tsep)
                                        (?P<seconds>\d\d?
                                            (?:[.,]\d+)?
                                        )
                                    )?
                                )?'''.format(**self.locale.re_values)

        self.RE_NLP_PREFIX = r'''(?P<nlp_prefix>
                                    (on)
                                    (\s)+1
                                    |
                                    (at|in)
                                    (\s)+2
                                    |
                                    (in)
                                    (\s)+3
                                )'''

        if 'meridian' in self.locale.re_values:
            self.RE_TIMEHMS2 += r'\s?(?P<meridian>({meridian}))'.format(**self.locale.re_values)

        dateSeps = ''.join(self.locale.dateSep) + '.'

        self.RE_DATE      = r'''(\s?|^)
                                (?P<date>(\d\d?[%s]\d\d?([%s]\d\d(\d\d)?)?))
                                (\s?|$|[^0-9a-zA-Z])''' % (dateSeps, dateSeps)

        self.RE_DATE2     = r'[%s]' % dateSeps

        assert 'dayoffsets' in self.locale.re_values

        self.RE_DAY       = r'''(\s|^)
                                (?P<day>
                                    ({dayoffsets})
                                )
                                (\s|$|[^0-9a-zA-Z])'''.format(**self.locale.re_values)

        self.RE_DAY2      = r'''(?P<day>\d\d?)
                                (?P<suffix>{daysuffix})?
                            '''.format(**self.locale.re_values)

        # self.RE_TIME      = r'''(\s?|^)
        #                         (?P<time>(morning|breakfast|noon|lunch|evening|midnight|tonight|dinner|night|now))
        #                         (\s?|$|[^0-9a-zA-Z])''' % self.locale.re_values

        self.RE_TIME      = r'''(\s?|^)
                                (?P<time>
                                    ({sources})
                                )
                                (\s?|$|[^0-9a-zA-Z])'''.format(**self.locale.re_values)

        self.RE_REMAINING = r'\s+'

        # Regex for date/time ranges
        self.RE_RTIMEHMS  = r'''(\s?|^)
                                (\d\d?){timeseperator}
                                (\d\d)
                                ({timeseperator}(\d\d))?
                                (\s?|$)'''.format(**self.locale.re_values)

        self.RE_RTIMEHMS2 = r'''(\s?|^)
                                (\d\d?)
                                ({timeseperator}(\d\d?))?
                                ({timeseperator}(\d\d?))?'''.format(**self.locale.re_values)

        if 'meridian' in self.locale.re_values:
            self.RE_RTIMEHMS2 += r'\s?({meridian})'.format(**self.locale.re_values)

        self.RE_RDATE  = r'(\d+([%s]\d+)+)' % dateSeps
        self.RE_RDATE3 = r'''(
                                (
                                    (
                                        ({months})
                                    )\s?
                                    (
                                        (\d\d?)
                                        (\s?|{daysuffix}|$)+
                                    )?
                                    (,\s?\d\d\d\d)?
                                )
                            )'''.format(**self.locale.re_values)

        # "06/07/06 - 08/09/06"
        self.DATERNG1 = self.RE_RDATE + r'\s?{rangeseperator}\s?' + self.RE_RDATE
        self.DATERNG1 = self.DATERNG1.format(**self.locale.re_values)

        # "march 31 - june 1st, 2006"
        self.DATERNG2 = self.RE_RDATE3 + r'\s?{rangeseperator}\s?' + self.RE_RDATE3
        self.DATERNG2 = self.DATERNG2.format(**self.locale.re_values)

        # "march 1rd -13th"
        self.DATERNG3 = self.RE_RDATE3 + r'\s?{rangeseperator}\s?(\d\d?)\s?(rd|st|nd|th)?'
        self.DATERNG3 = self.DATERNG3.format(**self.locale.re_values)

        # "4:00:55 pm - 5:90:44 am", '4p-5p'
        self.TIMERNG1 = self.RE_RTIMEHMS2 + r'\s?{rangeseperator}\s?' + self.RE_RTIMEHMS2
        self.TIMERNG1 = self.TIMERNG1.format(**self.locale.re_values)

        self.TIMERNG2 = self.RE_RTIMEHMS + r'\s?{rangeseperator}\s?' + self.RE_RTIMEHMS
        self.TIMERNG2 = self.TIMERNG2.format(**self.locale.re_values)

        # "4-5pm "
        self.TIMERNG3 = r'\d\d?\s?{rangeseperator}\s?' + self.RE_RTIMEHMS2
        self.TIMERNG3 = self.TIMERNG3.format(**self.locale.re_values)

        # "4:30-5pm "
        self.TIMERNG4 = self.RE_RTIMEHMS + r'\s?{rangeseperator}\s?' + self.RE_RTIMEHMS2
        self.TIMERNG4 = self.TIMERNG4.format(**self.locale.re_values)

        self.re_option = re.IGNORECASE + re.VERBOSE
        self.cre_source = { 'CRE_SPECIAL':   self.RE_SPECIAL,
                            'CRE_NUMBER':    self.RE_NUMBER,
                            'CRE_UNITS':     self.RE_UNITS,
                            'CRE_QUNITS':    self.RE_QUNITS,
                            'CRE_MODIFIER':  self.RE_MODIFIER,
                            'CRE_MODIFIER2': self.RE_MODIFIER2,
                            'CRE_TIMEHMS':   self.RE_TIMEHMS,
                            'CRE_TIMEHMS2':  self.RE_TIMEHMS2,
                            'CRE_DATE':      self.RE_DATE,
                            'CRE_DATE2':     self.RE_DATE2,
                            'CRE_DATE3':     self.RE_DATE3,
                            'CRE_DATE4':     self.RE_DATE4,
                            'CRE_MONTH':     self.RE_MONTH,
                            'CRE_WEEKDAY':   self.RE_WEEKDAY,
                            'CRE_DAY':       self.RE_DAY,
                            'CRE_DAY2':      self.RE_DAY2,
                            'CRE_TIME':      self.RE_TIME,
                            'CRE_REMAINING': self.RE_REMAINING,
                            'CRE_RTIMEHMS':  self.RE_RTIMEHMS,
                            'CRE_RTIMEHMS2': self.RE_RTIMEHMS2,
                            'CRE_RDATE':     self.RE_RDATE,
                            'CRE_RDATE3':    self.RE_RDATE3,
                            'CRE_TIMERNG1':  self.TIMERNG1,
                            'CRE_TIMERNG2':  self.TIMERNG2,
                            'CRE_TIMERNG3':  self.TIMERNG3,
                            'CRE_TIMERNG4':  self.TIMERNG4,
                            'CRE_DATERNG1':  self.DATERNG1,
                            'CRE_DATERNG2':  self.DATERNG2,
                            'CRE_DATERNG3':  self.DATERNG3,
                            'CRE_NLP_PREFIX': self.RE_NLP_PREFIX,
                          }
        self.cre_keys = list(self.cre_source.keys())

    def __getattr__(self, name):
        if name in self.cre_keys:
            value = re.compile(self.cre_source[name], self.re_option)
            setattr(self, name, value)
            return value
        elif name in self.locale.locale_keys:
            return getattr(self.locale, name)
        else:
            raise AttributeError(name)

    def daysInMonth(self, month, year):
        """
        Take the given month (1-12) and a given year (4 digit) return
        the number of days in the month adjusting for leap year as needed
        """
        result = None
        log.debug('daysInMonth(%s, %s)' % (month, year))
        if month > 0 and month <= 12:
            result = self._DaysInMonthList[month - 1]

            if month == 2:
                if year in self._leapYears:
                    result += 1
                else:
                    if calendar.isleap(year):
                        self._leapYears.append(year)
                        result += 1

        return result

    def buildSources(self, sourceTime=None):
        """
        Return a dictionary of date/time tuples based on the keys
        found in self.re_sources.

        The current time is used as the default and any specified
        item found in self.re_sources is inserted into the value
        and the generated dictionary is returned.
        """
        if sourceTime is None:
            (yr, mth, dy, hr, mn, sec, wd, yd, isdst) = time.localtime()
        else:
            (yr, mth, dy, hr, mn, sec, wd, yd, isdst) = sourceTime

        sources  = {}
        defaults = { 'yr': yr, 'mth': mth, 'dy':  dy,
                     'hr': hr, 'mn':  mn,  'sec': sec, }

        for item in self.re_sources:
            values = {}
            source = self.re_sources[item]

            for key in list(defaults.keys()):
                if key in source:
                    values[key] = source[key]
                else:
                    values[key] = defaults[key]

            sources[item] = ( values['yr'], values['mth'], values['dy'],
                              values['hr'], values['mn'], values['sec'], wd, yd, isdst )

        return sources


