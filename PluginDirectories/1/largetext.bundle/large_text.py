import sys
from AppKit import NSApplication, NSWindow, NSApp, NSBorderlessWindowMask, NSBackingStoreBuffered, NSScreen, NSView, NSColor, NSBezierPath, NSAnimationContext, NSTimer, NSApplicationActivationPolicyAccessory, NSMainMenuWindowLevel, NSAttributedString, NSFont, NSCenterTextAlignment, NSFontAttributeName, NSMutableParagraphStyle, NSParagraphStyleAttributeName, NSForegroundColorAttributeName, NSStringDrawingUsesLineFragmentOrigin, NSMakeRect, NSInsetRect, NSMakeSize, NSWindowCollectionBehaviorStationary, NSWindowCollectionBehaviorIgnoresCycle, NSWindowCollectionBehaviorCanJoinAllSpaces
from Quartz.QuartzCore import CAMediaTimingFunction, kCAMediaTimingFunctionEaseInEaseOut

dismissing = False

class Window(NSWindow):
	def keyDown_(self, event):
		self.fadeOut()
	
	def mouseDown_(self, event):
		self.fadeOut()
	
	def canBecomeKeyWindow(self):
		return True
	
	def canBecomeMainWindow(self):
		return True
	
	def resignKeyWindow(self):
		super(Window, self).resignKeyWindow()
		self.fadeOut()
	
	def constrainFrameRect_toScreen_(self, frame, screen):
		return frame
	
	def becomeMainWindow(self):
		super(Window, self).becomeMainWindow()
		NSAnimationContext.beginGrouping()
		NSAnimationContext.currentContext().setTimingFunction_(CAMediaTimingFunction.functionWithName_(kCAMediaTimingFunctionEaseInEaseOut))
		NSAnimationContext.currentContext().setDuration_(0.2)
		self.animator().setAlphaValue_(1)
		NSAnimationContext.endGrouping()
	
	def fadeOut(self):
		global dismissing
		if dismissing: return
		dismissing = True
		NSAnimationContext.beginGrouping()
		NSAnimationContext.currentContext().setTimingFunction_(CAMediaTimingFunction.functionWithName_(kCAMediaTimingFunctionEaseInEaseOut))
		NSAnimationContext.currentContext().setDuration_(0.2)
		self.animator().setAlphaValue_(0.0)
		NSAnimationContext.endGrouping()
		NSTimer.scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_(0.21, app, "terminate:", None, False)
		

app = NSApplication.sharedApplication()
app.setActivationPolicy_(NSApplicationActivationPolicyAccessory)
frame = NSScreen.mainScreen().frame()
window = Window.alloc().initWithContentRect_styleMask_backing_defer_(frame, NSBorderlessWindowMask, NSBackingStoreBuffered, False)
window.setLevel_(NSMainMenuWindowLevel+2)

text = sys.argv[1].decode('utf-8')

def attributed_text_at_size(text, size):
	paragraph_style = NSMutableParagraphStyle.new()
	paragraph_style.setAlignment_(NSCenterTextAlignment)
	attrs = {
		NSParagraphStyleAttributeName: paragraph_style,
		NSFontAttributeName: NSFont.boldSystemFontOfSize_(size),
		NSForegroundColorAttributeName: NSColor.whiteColor()
	}
	return NSAttributedString.alloc().initWithString_attributes_(text, attrs)

def attr_string_fits_in_rect(attr_string, rect):
	height = attr_string.boundingRectWithSize_options_(NSMakeSize(rect.size.width, 99999), NSStringDrawingUsesLineFragmentOrigin).size.height
	return height <= rect.size.height

class TextView(NSView):
	def drawRect_(self, rect):
		rect = NSInsetRect(rect, 40, 40)
		size = 50
		stride = 10
		while attr_string_fits_in_rect(attributed_text_at_size(text, size+stride), rect):
			size += stride
		attr = attributed_text_at_size(text, size)
		attr.drawInRect_(rect)

window.setExcludedFromWindowsMenu_(True)
window.setOpaque_(False)
window.setBackgroundColor_(NSColor.colorWithWhite_alpha_(0, 0.7))
window.setAlphaValue_(0)
window.setCollectionBehavior_(NSWindowCollectionBehaviorCanJoinAllSpaces | NSWindowCollectionBehaviorStationary | NSWindowCollectionBehaviorIgnoresCycle)

window.setContentView_(TextView.new())

NSApp.activateIgnoringOtherApps_(True)
window.makeKeyAndOrderFront_(None)


from PyObjCTools import AppHelper
AppHelper.runEventLoop()
