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
		h1 {
			font-size: 1.5em;
			margin-bottom: 0px;
		}
		p {
			margin-top: 5px;
			opacity: 0.7;
		}
		@font-face { font-family: icomoon; src: url('icomoon.ttf'); } 

		[class^="icon-"], [class*=" icon-"] {
			font-family: 'icomoon';
			speak: none;
			font-style: normal;
			font-weight: normal;
			font-variant: normal;
			text-transform: none;

			/* Better Font Rendering =========== */
			-webkit-font-smoothing: antialiased;
			-moz-osx-font-smoothing: grayscale;
		}

		.icon-phone:before {
			content: "\e600";
			font-size: 0.8em;
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
