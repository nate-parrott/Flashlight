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
		a.link, a.visited {
			color: <!--COLOR-->;
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
			font-size: large;
			font-weight: 200;
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
		
		
		@font-face {
			font-family: 'icomoon';
			src:url('icomoon.ttf') format('truetype');
			font-weight: normal;
			font-style: normal;
		}

		[class^="icon-"], [class*=" icon-"] {
			font-family: 'icomoon';
			speak: none;
			font-style: normal;
			font-weight: normal;
			font-variant: normal;
			text-transform: none;
			line-height: 1;

			/* Better Font Rendering =========== */
			-webkit-font-smoothing: antialiased;
			-moz-osx-font-smoothing: grayscale;
		}

		.icon-cloud-upload:before {
			content: "\e600";
		}

		</style>
		<body>
		<div id='centered'>
		<div>
			<div style='font-size: 60px'><span class='icon-cloud-upload'></span></div>
			<!--HTML-->
		</div>
		</div>
		<div id='hint'>
		<!--HINT-->
		</div>
		</body>
	"""
	return base.replace("<!--COLOR-->", text_color).replace("<!--HTML-->", html).replace("<!--HINT-->", hint_text)
