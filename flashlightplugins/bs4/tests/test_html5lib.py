"""Tests to ensure that the html5lib tree builder generates good trees."""

import warnings

try:
    from bs4.builder import HTML5TreeBuilder
    HTML5LIB_PRESENT = True
except ImportError, e:
    HTML5LIB_PRESENT = False
from bs4.element import SoupStrainer
from bs4.testing import (
    HTML5TreeBuilderSmokeTest,
    SoupTest,
    skipIf,
)

@skipIf(
    not HTML5LIB_PRESENT,
    "html5lib seems not to be present, not testing its tree builder.")
class HTML5LibBuilderSmokeTest(SoupTest, HTML5TreeBuilderSmokeTest):
    """See ``HTML5TreeBuilderSmokeTest``."""

    @property
    def default_builder(self):
        return HTML5TreeBuilder()

    def test_soupstrainer(self):
        # The html5lib tree builder does not support SoupStrainers.
        strainer = SoupStrainer("b")
        markup = "<p>A <b>bold</b> statement.</p>"
        with warnings.catch_warnings(record=True) as w:
            soup = self.soup(markup, parse_only=strainer)
        self.assertEqual(
            soup.decode(), self.document_for(markup))

        self.assertTrue(
            "the html5lib tree builder doesn't support parse_only" in
            str(w[0].message))

    def test_correctly_nested_tables(self):
        """html5lib inserts <tbody> tags where other parsers don't."""
        markup = ('<table id="1">'
                  '<tr>'
                  "<td>Here's another table:"
                  '<table id="2">'
                  '<tr><td>foo</td></tr>'
                  '</table></td>')

        self.assertSoupEquals(
            markup,
            '<table id="1"><tbody><tr><td>Here\'s another table:'
            '<table id="2"><tbody><tr><td>foo</td></tr></tbody></table>'
            '</td></tr></tbody></table>')

        self.assertSoupEquals(
            "<table><thead><tr><td>Foo</td></tr></thead>"
            "<tbody><tr><td>Bar</td></tr></tbody>"
            "<tfoot><tr><td>Baz</td></tr></tfoot></table>")
