Flashlight
==========

_The missing Spotlight plugin system_

<img src='https://raw.github.com/nate-parrott/flashlight/master/WeatherExampleImage.png' width=400/> <img src='https://raw.github.com/nate-parrott/flashlight/master/UIExampleImage.png' width=200 />

Flashlight is an **unofficial Spotlight API** that allows you to programmatically process queries and add additional results. It's *very rough right now,* and a *horrendous hack*, but a fun proof of concept.

**Installation**

Clone and build using Xcode, or [download Flashlight.app from _releases_](https://github.com/nate-parrott/Flashlight/releases).

**API**

The best way to get started writing a plugin is to copy an existing one and modify it. Try installing a simple plugin like 'say' or 'Pig latin,' and find it in `[your-user-directory]/Library/FlashlightPlugins`. Right click and 'show bundle contents,' then open the `executable` in a text editor. Plugins don't need to be reloaded.

Flashlight plugins are `.bundle` files in `~/Library/FlashlightPlugins`. They have a simple directory structure:

```
- MyPlugin.bundle
  - executable 
  		(probably a script in your favorite language, starting with #!/usr/bin/python|ruby|php|bash)
  - Info.plist
     (create these with Xcode. Must contain 'CFBundleDisplayName' and 'Description' keys)
```

When you enter text into Spotlight, Flashlight will invoke all the `*.bundle/executable` files. (in order for the system to know what interpreter to use, you've got to include the [shebang line](http://en.wikipedia.org/wiki/Shebang_(Unix)).)

Flashlight will pass the Spotlight query as the first argument (`argv[1]`).

If you want to show a search result, just print a JSON structure to stdout:

```
{
	"title": "Search result title",
	"html": "<h1>HTML to show inline <em>inside Spotlight</em></h1>",
	"execute": "bash shell script to run if the user hits enter"
}
```

For examples, look at the ['say' example](https://github.com/nate-parrott/Flashlight/tree/master/PluginDirectory/say.bundle) or the [Pig Latin example](https://github.com/nate-parrott/Flashlight/tree/master/PluginDirectory/piglatin.bundle).

**Please note that currently, no results are returned from Flashlight plugins until _all_ plugins finish.** If you need to do slow things like network requests or serious computation, please do this in Javascript inside your html. The [weather plugin](https://github.com/nate-parrott/Flashlight/tree/master/PluginDirectory/weather.bundle) is a good example of this.


**How it works**

The `Flashlight.app` Xcode target is a fork of [EasySIMBL](https://github.com/norio-nomura/EasySIMBL) (which is designed to allow loading runtime injection of plugins into arbitrary apps) that's been modified to load a single plugin (stored inside its own bundle, rather than an external directory) into the Spotlight process. It should be able to coexist with EasySIMBL if you use it.

The SIMBL plugin that's loaded into Spotlight, `SpotlightSIMBL.bundle`, patches Spotlight to add a new subclass of `SPQuery`, the internal class used to fetch results from different sources. It runs executables in `~/Library/FlashlightPlugins/*/executable`, and then presents their results using a custom subclass of `SPResult`.

Since [I'm not sure how to subclass classes that aren't available at link time](http://stackoverflow.com/questions/26704130/subclass-objective-c-class-without-linking-with-the-superclass), subclasses of Spotlight internal classes are made at runtime using [Mike Ash's instructions and helper code](https://www.mikeash.com/pyblog/friday-qa-2010-11-19-creating-classes-at-runtime-for-fun-and-profit.html).

The Spotlight plugin is gated to run only on version `911` (which ships in Yosemite 14A361c). If a new version of Spotlight comes out, you can manually edit `SpotlightSIMBL/SpotlightSIMBL/Info.plist` key `SIMBLTargetApplications.MaxBundleVersion`, restarts Spotlight, verify everything works, and then submit a pull request.
