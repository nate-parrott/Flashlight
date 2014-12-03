"""
Tests the _convertUnitAsWords method.
"""

import unittest
import parsedatetime as pdt


class test(unittest.TestCase):
    def setUp(self):
        self.cal   = pdt.Calendar()
        self.tests = (('one', 1),
                      ('zero', 0),
                      ('eleven', 11),
                      ('forty two', 42),
                      ('four hundred and fifteen', 415),
                      ('twelve thousand twenty', 12020),
                      ('nine hundred and ninety nine', 999),
                      ('three quintillion four billion', 3000000004000000000),
                      ('forty three thousand, nine hundred and ninety nine', 43999),
                      ('one hundred thirty three billion four hundred thousand three hundred fourteen', 133000400314)
                      )

    def testConversions(self):
        for pair in self.tests:
            self.assertTrue(self.cal._convertUnitAsWords(pair[0]) == pair[1])

if __name__ == "__main__":
    unittest.main()