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
			overflow-x: hidden;
		}
		body > #centered {
			display: table;
			width: 100%;
			height: 100%
		}
		body > #centered > div {
			display: table-cell;
			vertical-align: middle;
			line-height: 1.1;
			padding: 30px;
		}
		.file {
			display: table;
		}
		.file > div {
			display: table-cell;
			vertical-align: middle;
		}
		.file h2, .file p {
			margin: 6px;
			font-size: 1em;
		}
		.file p {
			opacity: 0.5;
		}
		.file img {
			width: 50px;
		}
		.file p {
			font-size: x-small;
		}
		.file {
			text-align: left;
		}
		h1 {
			font-size: small;
			text-transform: uppercase;
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
