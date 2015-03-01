import sys
from AppKit import NSApplication, NSWindow, NSApp, NSBorderlessWindowMask, NSBackingStoreBuffered, NSScreen, NSView, NSColor, NSBezierPath, NSAnimationContext, NSTimer, NSApplicationActivationPolicyAccessory, NSMainMenuWindowLevel, NSAttributedString, NSFont, NSCenterTextAlignment, NSFontAttributeName, NSMutableParagraphStyle, NSParagraphStyleAttributeName, NSForegroundColorAttributeName, NSStringDrawingUsesLineFragmentOrigin, NSMakeRect, NSInsetRect, NSMakeSize, NSColorPanel, NSButton, NSRoundedBezelStyle, NSViewMaxXMargin, NSViewMinXMargin, NSViewMaxYMargin, NSViewMinYMargin, NSObject, NSNotificationCenter, NSWindowDidResignKeyNotification, NSPasteboard, NSPasteboardTypeString, NSColorSpace
from Quartz.QuartzCore import CAMediaTimingFunction, kCAMediaTimingFunctionEaseInEaseOut

app = NSApplication.sharedApplication()
app.setActivationPolicy_(NSApplicationActivationPolicyAccessory)

format = sys.argv[1]

def copy_to_clipboard(text):
	NSPasteboard.generalPasteboard().clearContents()
	NSPasteboard.generalPasteboard().setString_forType_(text, NSPasteboardTypeString)

def color_to_hex(rgba):
	return "#{:02x}{:02x}{:02x}".format(*[int(c*255) for c in rgba[:3]])

def color_to_uicolor(rgba):
	return "[UIColor colorWithRed:{0} green:{1} blue:{2} alpha:{3}]".format(*rgba)

def color_to_uicolor_swift(rgba):
	return "UIColor(red: {0}, green:{1}, blue:{2}, alpha:{3})".format(*rgba)

def color_to_rgba(rgba):
	r,g,b,a = rgba
	return "rgba({0}, {1}, {2}, {3})".format(int(r*255), int(g*255), int(b*255), a)

def color_to_rgb(rgba):
	r,g,b,a = rgba
	return "rgba({0}, {1}, {2})".format(int(r*255), int(g*255), int(b*255))

class Callback(NSObject):
	def copy(self):
		nscolor = panel.color().colorUsingColorSpace_(NSColorSpace.deviceRGBColorSpace())
		r = nscolor.redComponent()
		g = nscolor.greenComponent()
		b = nscolor.blueComponent()
		a = panel.alpha()
		color = r,g,b,a
		copy_to_clipboard({
			"hex": color_to_hex,
			"uicolor": color_to_uicolor,
			"uicolor_swift": color_to_uicolor_swift,
			"rgba": color_to_rgba,
			"rgb": color_to_rgb
		}.get(format, color_to_hex)(color))
		self.close()

	def close(self):
		app.terminate_(None)
cb = Callback.alloc().init()

accessory = NSView.alloc().initWithFrame_(NSMakeRect(0,0,200,34))
for i, name in enumerate(['Cancel', 'Copy']):
	button = NSButton.alloc().init()
	button.setBezelStyle_(NSRoundedBezelStyle)
	button.setTitle_(name)
	button.sizeToFit()
	x = (i + 0.5) / 2 * 200 - button.frame().size.width / 2
	frame = NSMakeRect(x, (34 - button.frame().size.height)/2, button.frame().size.width, button.frame().size.height)
	button.setFrame_(frame)
	button.setAutoresizingMask_(NSViewMaxXMargin | NSViewMinXMargin | NSViewMaxYMargin | NSViewMinYMargin)
	button.setTarget_(cb)
	button.setAction_({"Cancel": "close", "Copy": "copy"}[name])
	accessory.addSubview_(button)

NSApp.activateIgnoringOtherApps_(True)
panel = NSColorPanel.sharedColorPanel()
panel.setShowsAlpha_(True)
panel.setAccessoryView_(accessory)
panel.makeKeyAndOrderFront_(None)

NSNotificationCenter.defaultCenter().addObserver_selector_name_object_(cb, "close", NSWindowDidResignKeyNotification, panel)

from PyObjCTools import AppHelper
AppHelper.runEventLoop()
cb.copy()
