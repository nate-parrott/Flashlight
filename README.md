Flashlight
==========

Flashlight is an *unofficial Spotlight API* that allows you to programmatically process queries and add additional results. It's **very rough right now,** and a **horrendous hack**, but a fun proof of concept.

*Installation*
Flashlight depends on [EasySIMBL](https://github.com/norio-nomura/EasySIMBL), a runtime code-injection framework. (like MobileSubstrate, but for OS X). 

When you build and run the Xcode project, it generates a bundle called `SpotlightSIMBL.bundle`, automatically copies it to `~/Library/Application Support/SIMBL/Plugins`, then restarts Spotlight.

*API*
After installation, whenever you enter text into Spotlight, Flashlight tries to execute all the files in `~/Library/FlashlightPlugins`, passing your query as the first argument. (`argv[1]`) If they decide to respond to the query, they should print a json document to `stdout` in this format:

```
{
	"title": "'Hello world' in Pig Latin",
	"html": "<h1>ellohay, orldway</h1>"
}
```

This HTML will then be presented to the user:

![Image of a Spotlight window showing 'ellohay orldway' as the Pig Latin translation of 'hello world'](https://raw.github.com/nate-parrott/flashlight/master/PigLatinExampleImage.png)

This is currently all the API does. More capabilities — custom actions when the user presses enter, or more customization of the search result — are on my to-do list.
