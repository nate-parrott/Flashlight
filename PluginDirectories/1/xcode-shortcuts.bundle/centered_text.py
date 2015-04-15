def dark_mode():
    import Foundation
    return Foundation.NSUserDefaults.standardUserDefaults().persistentDomainForName_(Foundation.NSGlobalDomain).objectForKey_("AppleInterfaceStyle") == "Dark"

def centered_text(html, hint_text=""):
	text_color = "white" if dark_mode() else "black"
	base = u"""
		<style>
		html, body {
			margin: 0px;
			width: 100%;
			height: 100%;
			color: <!--COLOR-->;
			font-family: "HelveticaNeue";
		}
		body > #centered {
			display: table;
			width: 100%;
			height: 100%
		}
		body > #centered > div {
			display: table-cell;
			vertical-align: middle;
			text-align: center;
			font-size: x-large;
			line-height: 1.1;
			padding: 30px;
		}
		#hint {
			opacity: 0.5;
			font-weight: bold;
			font-size: small;
			position: absolute;
			left: 10px;
			right: 10px;
			bottom: 10px;
			text-align: center;
		}
		</style>
		<body>
		<div id='centered'>
		<div>
			<!--HTML-->
		</div>
		</div>
		<div id='hint'>
		<!--HINT-->
		</div>
		</body>
	"""
	return base.replace("<!--COLOR-->", text_color).replace("<!--HTML-->", html).replace("<!--HINT-->", hint_text)
