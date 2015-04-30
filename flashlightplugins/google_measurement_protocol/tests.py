from unittest import TestCase
try:
    from urllib.parse import parse_qs
except ImportError:
    from urlparse import parse_qs

from httmock import response, urlmatch, with_httmock
from prices import Price

from . import (Event, Item, PageView, report, SystemInfo, Requestable,
               Transaction, payloads)


class MockRequestable(Requestable):

    def get_payload(self):
        return {'t': 'mock'}


@urlmatch(netloc=r'ssl\.google-analytics\.com', path='/collect')
def ga_mock(url, request):
    qs = parse_qs(request.body)
    return response(200, qs)


class ReportTest(TestCase):

    @with_httmock(ga_mock)
    def test_report(self):
        mr = MockRequestable()
        (response,) = report('UA-123456-78', 'CID', mr)
        data = response.json()
        self.assertEqual(data['cid'], ['CID'])
        self.assertEqual(data['tid'], ['UA-123456-78'])
        self.assertEqual(data['t'], ['mock'])

    @with_httmock(ga_mock)
    def test_extra_info(self):
        empty_info = SystemInfo()
        self.assertEqual(empty_info.get_payload(), {})
        mr = MockRequestable()
        info = SystemInfo(language='en-gb')
        (response,) = report('UA-123456-78', 'CID', mr, extra_info=info)
        data = response.json()
        self.assertEqual(data['ul'], ['en-gb'])


class PageViewTest(TestCase):

    def test_by_path(self):
        pv1 = PageView('/my-page/')
        self.assertEqual(pv1.get_payload(),
                         {'t': 'pageview', 'dp': '/my-page/'})
        pv2 = PageView('/my-page/', host_name='example.com')
        self.assertEqual(
            pv2.get_payload(),
            {'t': 'pageview', 'dp': '/my-page/', 'dh': 'example.com'})

    def test_by_location(self):
        view = PageView(location='http://example.com/my-page/')
        self.assertEqual(
            view.get_payload(),
            {'t': 'pageview', 'dl': 'http://example.com/my-page/'})

    def test_optional_params(self):
        view = PageView('/', title='title', referrer='referrer')
        self.assertEqual(
            view.get_payload(),
            {'t': 'pageview', 'dp': '/', 'dr': 'referrer', 'dt': 'title'})


class EventTest(TestCase):

    def test_required_params(self):
        evt = Event('category', 'action')
        self.assertEqual(evt.get_payload(),
                         {'t': 'event', 'ec': 'category', 'ea': 'action'})

    def test_optional_params(self):
        evt = Event('category', 'action', label='label', value=7)
        self.assertEqual(
            evt.get_payload(),
            {'t': 'event', 'ec': 'category', 'ea': 'action', 'el': 'label',
             'ev': '7'})


class ItemTest(TestCase):

    def test_required_params(self):
        item = Item('item-01', Price(10, currency='USD'))
        self.assertEqual(
            item.get_payload_for_transaction('trans-01'),
            {'t': 'item', 'in': 'item-01', 'cu': 'USD', 'ip': '10',
             'ti': 'trans-01'})

    def test_quantity(self):
        item = Item('item-01', Price(10, currency='USD'), quantity=2)
        self.assertEqual(
            item.get_payload_for_transaction('trans-01'),
            {'t': 'item', 'in': 'item-01', 'cu': 'USD', 'ip': '10',
             'iq': '2', 'ti': 'trans-01'})
        self.assertEqual(item.get_subtotal(), Price(20, currency='USD'))

    def test_optional_params(self):
        item = Item('item-01', Price(10, currency='USD'), item_id='it01',
                    category='cat')
        self.assertEqual(
            item.get_payload_for_transaction('trans-01'),
            {'t': 'item', 'in': 'item-01', 'cu': 'USD', 'ip': '10',
             'ic': 'it01', 'iv': 'cat', 'ti': 'trans-01'})


class TransactionTest(TestCase):

    def test_no_items(self):
        self.assertRaises(ValueError, lambda: Transaction('trans-01', []))

    def test_required_params(self):
        items = [Item('item-01', Price(10, currency='USD'))]
        trans = Transaction('trans-01', items)
        self.assertEqual(
            trans.get_payload(),
            {'t': 'transaction', 'ti': 'trans-01', 'cu': 'USD', 'tr': '10',
             'tt': '0'})

    def test_revenue_override(self):
        items = [Item('item-01', Price(10, currency='USD'))]
        trans = Transaction('trans-01', items,
                            revenue=Price(net=40, gross=50, currency='USD'))
        self.assertEqual(
            trans.get_payload(),
            {'t': 'transaction', 'ti': 'trans-01', 'cu': 'USD', 'tr': '50',
             'tt': '10'})

    def test_shipping(self):
        items = [Item('item-01', Price(10, currency='USD'))]
        trans = Transaction('trans-01', items,
                            shipping=Price(100, currency='USD'))
        self.assertEqual(
            trans.get_payload(),
            {'t': 'transaction', 'ti': 'trans-01', 'cu': 'USD', 'tr': '110',
             'ts': '100', 'tt': '0'})

    def test_affiliation(self):
        items = [Item('item-01', Price(10, currency='USD'))]
        trans = Transaction('trans-01', items, affiliation='loyalty')
        self.assertEqual(
            trans.get_payload(),
            {'t': 'transaction', 'ti': 'trans-01', 'cu': 'USD', 'tr': '10',
             'tt': '0', 'ta': 'loyalty'})

    def test_iter(self):
        items = [Item('item-01', Price(10, currency='USD')),
                 Item('item-02', Price(10, currency='USD'))]
        trans = Transaction('trans-01', items)
        trans_payloads = list(trans)
        self.assertEqual(len(trans_payloads), 3)


class PayloadsTest(TestCase):

    def test_payloads(self):
        items = [Item('item-01', Price(10, currency='USD')),
                 Item('item-02', Price(10, currency='USD'))]
        trans = Transaction('trans-01', items)
        trans_payloads = list(payloads(
            'tracking-id',
            'client-id',
            trans,
            SystemInfo(language='en-gb'),
            {'extra-header-key': 'extra-head-value'}))

        self.assertEqual(len(trans_payloads), 3)
        for data, headers in trans_payloads:
            self.assertEqual(data['tid'], 'tracking-id')
            self.assertEqual(data['cid'], 'client-id')
            self.assertEqual(data['ul'], 'en-gb')
            self.assertTrue(headers['extra-header-key'], 'extra-header-value')
